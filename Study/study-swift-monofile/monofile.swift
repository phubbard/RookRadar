// Import necessary modules
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

print("Swift GitHub API Demo")
print("Fetching the latest commit from a public repository...")

// Define the GitHub repository to query
let owner = "apple"
let repo = "swift"

// Create URL for GitHub API request
let urlString = "https://api.github.com/repos/\(owner)/\(repo)/commits?per_page=1"
guard let url = URL(string: urlString) else {
    print("Invalid URL")
    exit(1)
}

print("? Request URL: \(urlString)")

// Create a URLRequest with appropriate headers
var request = URLRequest(url: url)
request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
request.addValue("Swift-API-Demo", forHTTPHeaderField: "User-Agent")

print("? Making URLSession request with headers: \(request.allHTTPHeaderFields ?? [:])")

// Create a semaphore to make the async call synchronous
let semaphore = DispatchSemaphore(value: 0)
var responseData: Data?
var responseError: Error?

// Create URLSession task
let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
    defer { semaphore.signal() }
    
    if let error = error {
        responseError = error
        return
    }
    
    if let httpResponse = response as? HTTPURLResponse {
        print("? Received HTTP response status: \(httpResponse.statusCode)")
    }
    
    responseData = data
}

// Start the task
print("? Starting URLSession task")
task.resume()

// Wait for completion
print("? Waiting for response...")
semaphore.wait()

if let error = responseError {
    print("?? Network request failed: \(error)")
    exit(1)
}

guard let outputData = responseData else {
    print("?? No data received")
    exit(1)
}

print("? Received \(outputData.count) bytes of data")

// Print the raw JSON response
if let jsonString = String(data: outputData, encoding: .utf8) {
    print("? Raw JSON response:")
    print(jsonString)
} else {
    print("?? Could not convert response data to string")
}

do {
    // Parse JSON
    print("? Attempting to parse JSON...")
    let jsonObject = try JSONSerialization.jsonObject(with: outputData)
    print("? JSON parsed successfully, type: \(type(of: jsonObject))")
    
    if let jsonArray = jsonObject as? [[String: Any]] {
        print("? JSON successfully cast to array of dictionaries with \(jsonArray.count) items")
        
        if let commit = jsonArray.first {
            print("\nLatest Commit Details:")
            print("----------------------")
            
            // Extract commit details
            if let sha = commit["sha"] as? String {
                print("SHA: \(sha)")
            } else {
                print("?? Could not extract SHA")
            }
            
            if let commitDetails = commit["commit"] as? [String: Any] {
                print("? Found commit details dictionary")
                
                if let message = commitDetails["message"] as? String {
                    // Get just the first line of the commit message
                    let firstLine = message.split(separator: "\n").first ?? ""
                    print("Message: \(firstLine)")
                } else {
                    print("?? Could not extract commit message")
                }
                
                if let authorInfo = commitDetails["author"] as? [String: Any] {
                    print("? Found author info dictionary")
                    if let name = authorInfo["name"] as? String,
                       let date = authorInfo["date"] as? String {
                        print("Author: \(name)")
                        print("Date: \(date)")
                    } else {
                        print("?? Could not extract author name or date")
                    }
                } else {
                    print("?? Could not extract author info")
                }
            } else {
                print("?? Could not extract commit details")
            }
            
            // Get the HTML URL
            if let htmlUrl = commit["html_url"] as? String {
                print("URL: \(htmlUrl)")
            } else {
                print("?? Could not extract HTML URL")
            }
        } else {
            print("?? Array is empty, no commits found")
        }
    } else {
        print("?? Failed to parse JSON as expected array structure")
        print("? Actual type: \(type(of: jsonObject))")
        
        // Try to inspect the actual structure
        if let dictionary = jsonObject as? [String: Any] {
            print("? JSON is a dictionary with keys: \(dictionary.keys.joined(separator: ", "))")
            
            // Check if it's an error message from GitHub
            if let message = dictionary["message"] as? String {
                print("?? GitHub API message: \(message)")
            }
        }
    }
} catch {
    print("?? JSON parsing error: \(error)")
    if let jsonString = String(data: outputData, encoding: .utf8) {
        print("? Raw JSON response: \(jsonString)")
    }
}

