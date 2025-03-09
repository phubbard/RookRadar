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

// Use curl command-line instead of URLSession for better compatibility
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
process.arguments = [
    "-s",
    "-H", "Accept: application/vnd.github.v3+json",
    "-H", "User-Agent: Swift-API-Demo",
    urlString
]

let outputPipe = Pipe()
process.standardOutput = outputPipe

do {
    try process.run()
    process.waitUntilExit()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    
    if process.terminationStatus == 0 {
        // Successfully fetched data
        do {
            // Parse JSON
            if let jsonArray = try JSONSerialization.jsonObject(with: outputData) as? [[String: Any]],
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
            } else {
                print("Failed to parse JSON as expected array structure")
            }
        } catch {
            print("JSON parsing error: \(error)")
            if let jsonString = String(data: outputData, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }
        }
    } else {
        print("Command failed with status: \(process.terminationStatus)")
        if let errorOutput = String(data: outputData, encoding: .utf8) {
            print("Error output: \(errorOutput)")
        }
    }
} catch {
    print("Failed to run curl command: \(error)")
}


