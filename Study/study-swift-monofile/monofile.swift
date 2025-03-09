import Foundation

print("Swift GitHub API Demo")
print("Fetching the latest commit from a public repository...")

// Define the GitHub repository to query
let owner = "apple"
let repo = "swift"

// Create URL for GitHub API request
let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/commits?per_page=1")!

// Create a semaphore to wait for the async network request
let semaphore = DispatchSemaphore(value: 0)

// Create the request
var request = URLRequest(url: url)
request.httpMethod = "GET"
request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
request.addValue("Swift-API-Demo", forHTTPHeaderField: "User-Agent")

// Data task to fetch from GitHub
let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
    defer { semaphore.signal() }
    
    if let error = error {
        print("Error: \(error.localizedDescription)")
        return
    }
    
    guard let httpResponse = response as? HTTPURLResponse else {
        print("Invalid response")
        return
    }
    
    print("Response status code: \(httpResponse.statusCode)")
    
    if httpResponse.statusCode == 200, let data = data {
        do {
            // Parse JSON
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let commit = jsonArray.first {
                
                print("\nLatest Commit Details:")
                print("----------------------")
                
                // Extract commit details
                if let sha = commit["sha"] as? String {
                    print("SHA: \(sha)")
                }
                
                if let commitDetails = commit["commit"] as? [String: Any] {
                    if let message = commitDetails["message"] as? String {
                        // Get just the first line of the commit message
                        let firstLine = message.split(separator: "\n").first ?? ""
                        print("Message: \(firstLine)")
                    }
                    
                    if let authorInfo = commitDetails["author"] as? [String: Any],
                       let name = authorInfo["name"] as? String,
                       let date = authorInfo["date"] as? String {
                        print("Author: \(name)")
                        print("Date: \(date)")
                    }
                }
                
                // Get the HTML URL
                if let htmlUrl = commit["html_url"] as? String {
                    print("URL: \(htmlUrl)")
                }
            }
        } catch {
            print("JSON parsing error: \(error.localizedDescription)")
        }
    } else {
        print("Failed to get data")
        if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
            print("Error message: \(errorMessage)")
        }
    }
}

// Start the request
task.resume()

// Wait for the request to complete
_ = semaphore.wait(timeout: .distantFuture)

