// Import necessary modules
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

print("=== Swift GitHub API Demo - Enhanced Debugging ===")
print("Starting at: \(Date())")

// Define the GitHub repository to query
let owner = "apple"
let repo = "swift"

// Create URL for GitHub API request
let urlString = "https://api.github.com/repos/\(owner)/\(repo)/commits?per_page=1"
guard let url = URL(string: urlString) else {
    print("[FATAL] Invalid URL")
    exit(1)
}

print("[CONFIG] Request URL: \(urlString)")

// Create custom URLSession configuration BEFORE creating the session
print("[CONFIG] Creating custom URLSession configuration")
let config = URLSessionConfiguration.default
config.timeoutIntervalForRequest = 30.0  // Increase timeout to 30 seconds
config.requestCachePolicy = .reloadIgnoringLocalCacheData
config.httpShouldSetCookies = false
config.httpAdditionalHeaders = [
    "Accept": "application/vnd.github.v3+json",
    "User-Agent": "Swift-API-Demo-Enhanced"
]

print("[CONFIG] URLSession configuration: timeoutInterval=\(config.timeoutIntervalForRequest)")

// Create a dedicated URLSession with our configuration
print("[CONFIG] Creating URLSession with custom configuration")
let session = URLSession(configuration: config)

print("[ENV] Runtime environment:")
#if canImport(FoundationNetworking)
print("  - Using FoundationNetworking module")
#else
print("  - Using standard Foundation module")
#endif

// Create a direct URLRequest (without using the session's headers to be explicit)
print("[REQUEST] Creating URLRequest")
var request = URLRequest(url: url)
request.httpMethod = "GET"
request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
request.addValue("Swift-API-Demo-Enhanced", forHTTPHeaderField: "User-Agent")
request.timeoutInterval = 30.0  // Set explicitly on the request too

print("[REQUEST] URLRequest created with headers: \(request.allHTTPHeaderFields ?? [:])")
print("[REQUEST] URLRequest timeout: \(request.timeoutInterval)")

// Create a semaphore for synchronous operation
let semaphore = DispatchSemaphore(value: 0)
var responseData: Data?
var responseError: Error?
var httpResponse: HTTPURLResponse?

// Create the URLSession task
print("[NETWORK] Creating data task")
let task = session.dataTask(with: request) { (data, response, error) in
    print("[CALLBACK] Entered completion handler at \(Date())")
    
    // Store the HTTP response
    httpResponse = response as? HTTPURLResponse
    
    // Log the HTTP status if available
    if let httpResponse = httpResponse {
        print("[RESPONSE] HTTP Status: \(httpResponse.statusCode)")
        print("[RESPONSE] Headers: \(httpResponse.allHeaderFields)")
    } else {
        print("[RESPONSE] No HTTP response received")
    }
    
    // Log and store error if present
    if let error = error {
        let nsError = error as NSError
        print("[ERROR] Code: \(nsError.code), Domain: \(nsError.domain)")
        print("[ERROR] Description: \(error.localizedDescription)")
        print("[ERROR] Underlying error: \(nsError.userInfo)")
        responseError = error
    } else {
        print("[RESPONSE] No error reported")
    }
    
    // Log and store data if present
    if let data = data {
        print("[RESPONSE] Received \(data.count) bytes")
        responseData = data
    } else {
        print("[RESPONSE] No data received")
    }
    
    // Signal completion
    print("[CALLBACK] Signaling semaphore")
    semaphore.signal()
}

// Start the task
print("[NETWORK] Starting data task at \(Date())")
task.resume()

// Wait with timeout (longer than the request timeout)
print("[WAIT] Waiting for response with 40 second timeout...")
let waitResult = semaphore.wait(timeout: .now() + 40.0)

// Check for timeout
if waitResult == .timedOut {
    print("[FATAL] Request timeout at semaphore level")
    // Try to cancel the task
    print("[CLEANUP] Attempting to cancel the task")
    task.cancel()
    exit(1)
}

print("[DONE] Semaphore was signaled")

// Check for errors
if let error = responseError {
    print("[ERROR] Request failed: \(error)")
    
    // Check if it's a redirect error and log that specifically
    if let httpResponse = httpResponse, (httpResponse.statusCode >= 300 && httpResponse.statusCode < 400) {
        print("[REDIRECT] Detected HTTP redirect (\(httpResponse.statusCode))")
        if let location = httpResponse.allHeaderFields["Location"] as? String {
            print("[REDIRECT] Target location: \(location)")
            print("[HINT] Swift may not be following redirects automatically")
        }
    }
    
    // Extra diagnostics for common error codes
    let nsError = error as NSError
    if nsError.domain == NSURLErrorDomain {
        switch nsError.code {
        case NSURLErrorTimedOut:
            print("[DIAGNOSTIC] This is a timeout error. Consider increasing timeoutIntervalForRequest.")
        case NSURLErrorCannotConnectToHost:
            print("[DIAGNOSTIC] Cannot connect to host. Possible network or firewall issue.")
        case NSURLErrorCannotFindHost:
            print("[DIAGNOSTIC] Cannot find host. Possible DNS resolution issue.")
        case NSURLErrorSecureConnectionFailed:
            print("[DIAGNOSTIC] Secure connection failed. Possible SSL/TLS issue.")
        default:
            print("[DIAGNOSTIC] NSURLError code: \(nsError.code)")
        }
    }
} else {
    print("[SUCCESS] Request completed without errors")
}

// Process data if available
if let data = responseData {
    print("[PROCESSING] Processing \(data.count) bytes of response data")
    
    do {
        // Try to parse as JSON
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("[JSON] Successfully parsed JSON with \(json.count) top-level keys")
            
            // Pretty print a portion of the JSON
            let prettyData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                let firstLines = prettyString.split(separator: "\n").prefix(20).joined(separator: "\n")
                print("\n[JSON PREVIEW]\n\(firstLines)\n...(truncated)...")
            }
        } else {
            // If not JSON, show as string
            if let responseString = String(data: data, encoding: .utf8) {
                print("\n[RESPONSE STRING]\n\(responseString)")
            } else {
                print("[ERROR] Could not convert response to string or JSON")
            }
        }
    } catch {
        print("[ERROR] JSON parsing failed: \(error)")
        
        // Show raw string if JSON parsing fails
        if let responseString = String(data: data, encoding: .utf8) {
            print("\n[RAW RESPONSE]\n\(responseString)")
        }
    }
} else {
    print("[ERROR] No data available to process")
}

// Check if redirect happened but wasn't followed
if let httpResponse = httpResponse, (httpResponse.statusCode >= 300 && httpResponse.statusCode < 400) {
    print("\n[WARNING] The request resulted in a redirect that wasn't automatically followed")
    print("[FIX] You may need to enable automatic redirect following or handle redirects manually")
}

// Final diagnostics
print("\n[SUMMARY]")
print("- Request URL: \(urlString)")
print("- HTTP Status: \(httpResponse?.statusCode ?? -1)")
print("- Received data: \(responseData?.count ?? 0) bytes")
print("- Error: \(responseError?.localizedDescription ?? "None")")
print("- Timing: \(Date())")
print("=== Demo Complete ===")

