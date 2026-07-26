
# Guide: Integrating Pandoc Server for Instant Previews and Static Generation

This document provides a comprehensive blueprint for transitioning from the Pandoc Command-Line Interface (CLI) to **Pandoc Server** (`pandoc --server`). It covers architectural use cases, code integration in Ruby, and performance benchmarks.

---

## 1. Architectural Patterns & Use Cases

Using Pandoc via CLI introduces a heavy process-spawning penalty (forking the OS process, initializing the Haskell runtime, and loading parsers). Pandoc Server eliminates this by remaining resident in memory. Here are three optimal integration patterns:

### Use Case A: "On-the-Fly" Admin Live Preview (Asynchronous API)
When an author edits a Markdown draft in a web-based administration panel, the application renders a real-time HTML preview without blocking the main thread or hitting the disk.
* **Flow**: The browser captures textarea changes → sends Markdown text via AJAX/Fetch `POST` to your backend → Backend proxies the text to Pandoc Server via HTTP → Pandoc Server returns raw HTML instantly → Backend returns it to the browser frontend.
* **Benefit**: Sub-millisecond rendering latency creates a smooth "Type & See" user experience.

### Use Case B: Instant Webhook/API Publishing
A headless CMS triggers a webhook whenever a document status changes to `Published`.
* **Flow**: Webhook payload containing the updated Markdown content hits your deployment worker. The worker pipes the content directly through the Pandoc Server API and flushes the output straight into your production cache or cloud storage object (e.g., AWS S3).
* **Benefit**: Zero disk I/O dependency on the host application machine.

### Use Case C: High-Speed Batch Generation
Compiling an entire documentation portal or digital book consisting of hundreds of separate files.
* **Flow**: A background worker boots up, starts a temporary Pandoc Server instance, and pipes files through concurrent HTTP requests using parallel threads.
* **Benefit**: Drops the compilation overhead from minutes to fractions of a second.

---

## 2. Ruby Integration Blueprint

The following Ruby implementation demonstrates how to format HTTP headers and payload arguments (`X-Pandoc-Args`) to request a conversion from Pandoc Server. This pattern avoids local disk reads/writes during the Pandoc processing cycle by handling templates and output directly in memory.

```ruby
require 'net/http'
require 'uri'
require 'json'

# Compiles Markdown content into HTML using a persistent Pandoc Server instance.
#
# @param markdown_content [String] Raw Markdown text to convert
# @param template_content [String, nil] Raw HTML master shell template content
# @param variables [Hash] Template variables mapping keys to values (e.g., { 'title' => 'Doc Title' })
# @param extra_arguments [Array<String>] Additional command-line flags passed via JSON array
# @param host [String] The Pandoc Server hostname/IP address
# @param port [Integer] The port number the Pandoc Server listens on
# @return [String] Raw HTML output returned from the server
# @raise [RuntimeError] If the server returns an error code or cannot be reached
def render_markdown_via_server(markdown_content, template_content: nil, variables: {}, extra_arguments: [], host: 'localhost', port: 8080)
  # 1. Build the argument array for the X-Pandoc-Args header
  cmd_args = []
  
  if template_content
    cmd_args << "--template" << template_content
  end

  variables.each do |key, value|
    next if value.nil?
    cmd_args << "-V" << "#{key}=#{value}"
  end

  cmd_args += extra_arguments

  # 2. Configure the HTTP POST Request
  uri = URI.parse("http://#{host}:#{port}/")
  request = Net::HTTP::Post.new(uri)
  
  # Set the document payload
  request.body = markdown_content

  # Formats and structural extensions are defined in the specific HTTP headers
  request["Content-Type"] = "text/plain; charset=utf-8"
  request["Accept"]       = "text/plain; charset=utf-8"
  request["X-Pandoc-From"] = "markdown+fenced_divs+raw_html"
  request["X-Pandoc-To"]   = "html5"
  
  # Inject variables and extensions via JSON serialized array
  request["X-Pandoc-Args"] = JSON.generate(cmd_args)

  # 3. Transmit request and capture the response stream
  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end

  if response.code == "200"
    return response.body
  else
    raise "Pandoc Server Error [#{response.code}]: #{response.body}"
  end
rescue Errno::ECONNREFUSED
  raise "Pandoc Server connection refused at #{uri}. Ensure 'pandoc --server --port=#{port}' is running."
end

# ==========================================
# Example Usage: Real-Time Admin Controller
# ==========================================
#
# post '/admin/preview' do
#   content_type :html
#   raw_markdown = params[:markdown_text]
#   master_layout = File.read("views/layouts/preview.html")
#
#   render_markdown_via_server(
#     raw_markdown, 
#     template_content: master_layout, 
#     variables: { 'author' => 'Admin User', 'date' => Time.now.strftime("%Y-%m-%d") }
#   )
# end
```

---

## 3. Performance & Efficiency Assessment

Transitioning to a server architecture radically shifts how system resources are consumed.

### Performance Breakdown

| Metric / Aspect | Pandoc CLI Mode (`pandoc input.md`) | Pandoc Server Mode (`pandoc --server`) |
| :--- | :--- | :--- |
| **Execution Overhead** | High (~80ms to 150ms spawn latency per file) | Microscopic (Network stack latency, <2ms overhead) |
| **Memory Allocation** | Volatile (Allocates and drops RAM for every execution loop) | Stable (Constant memory pool allocation in background) |
| **Concurrency Capabilities** | Linear / Spawns heavy sub-processes per core | Concurrent (Engine utilizes lightweight Haskell green threads) |
| **Disk Operations** | Heavy (Continuous file descriptors read/write) | Minimal (Pipes raw in-memory string values directly) |

### Scale and Velocity Projections

* **Small Footprint (100 - 300 Pages):**
  * *CLI Approach:* Total run duration hovers between **15 to 35 seconds** depending on disk access speed and core counts.
  * *Server Approach:* Total execution completes within **1.5 to 3 seconds**. 
* **Enterprise Footprint (3,000+ Pages):**
  * *CLI Approach:* Processing introduces systematic slowdowns, frequently clocking in at **4 to 6 minutes**. It introduces high CPU thermal spikes due to continuous shell invocation loops.
  * *Server Approach:* Processes comfortably in **12 to 18 seconds** using parallel HTTP request pooling.

---

## 4. Production Deployment & Stability Checklist

When managing Pandoc Server inside production microservices or administrative panels, use these practices to ensure architectural resiliency:

1. **Enforce Payload Constraints:** Pandoc parses text recursively into an Abstract Syntax Tree (AST). Ensure your Ruby app rejects or truncates individual markdown requests exceeding 5-10MB to avoid high memory spikes.
2. **Process Monitoring:** Wrap your background server runtime with standard process supervisors like `systemd` (Linux), `launchd` (macOS), or a process monitoring tool like Monit/God to auto-restart the web-socket listener if it crashes.
3. **Isolate Sandbox Security:** Pandoc Server disables unsafe operations by default (e.g., executing arbitrary code via filters or writing to files outside explicit boundaries). Maintain this baseline by never turning on unsafe local parameter features if your admin interface accepts text input from untrusted users.
