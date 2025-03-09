// Import necessary modules
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

print("Swift GitHub API Demo - Simple Version")
print("Fetching from GitHub API...")

// Define the GitHub repository to query
let owner = "apple"
let repo = "swift"

// Create URL for GitHub API request
let urlString = "https://api.github.com/repos/\(owner)/\(repo)/commits?per_page=1"
guard let url = URL(string: urlString) else {
    print("Invalid URL")
    exit(1)
}

print("[DEBUG] Request URL: \(urlString)")

#if canImport(FoundationNetworking)
print("[DEBUG] Using FoundationNetworking module")
#else
print("[DEBUG] Using standard Foundation module")
#endif

// Create a URLRequest with appropriate headers
var request = URLRequest(url: url)
request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
request.addValue("Swift-API-Demo", forHTTPHeaderField: "User-Agent")

print("[DEBUG] Making request with headers: \(request.allHTTPHeaderFields ?? [:])")

// Create a semaphore for synchronous operation
let semaphore = DispatchSemaphore(value: 0)
var responseData: Data?
var responseError: Error?

// Create the URLSession task
print("[DEBUG] Creating URLSession task")
let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
    print("[DEBUG] Entered completion handler")
    
    // Log the error if present
    if let error = error {
        print("[ERROR] \(error.localizedDescription)")
        responseError = error
    }
    
    // Log the response status
    if let httpResponse = response as? HTTPURLResponse {
        print("[DEBUG] HTTP Status: \(httpResponse.statusCode)")
    }
    
    // Store the data
    responseData = data
    
    // Signal completion
    print("[DEBUG] Signaling semaphore")
    semaphore.signal()
}

// Start the task
print("[DEBUG] Starting task")
task.resume()

// Set a custom session configuration
print("[DEBUG] Updating URLSession configuration")
URLSession.shared.configuration.timeoutIntervalForRequest = 10.0

// Wait with timeout
print("[DEBUG] Waiting for response...")
let waitResult = semaphore.wait(timeout: .now() + 10.0)

// Check for timeout
if waitResult == .timedOut {
    print("[ERROR] Request timed out")
    exit(1)
}

// Check for errors
if let error = responseError {
    print("[ERROR] Request failed: \(error)")
    exit(1)
}

// Process data if available
if let data = responseData {
    print("[DEBUG] Received \(data.count) bytes")
    
    if let responseString = String(data: data, encoding: .utf8) {
        print("\n[RESPONSE]")
        print(responseString)
    } else {
        print("[ERROR] Could not convert response to string")
    }
} else {
    print("[ERROR] No data received")
}

print("[DEBUG] Complete")

