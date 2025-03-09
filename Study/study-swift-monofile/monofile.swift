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

// Use curl command-line instead of URLSession for better compatibility
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
process.arguments = [
    "-s",
    "-H", "Accept: application/vnd.github.v3+json",
    "-H", "User-Agent: Swift-API-Demo",
    urlString
]

print("? Running curl command with arguments: \(process.arguments ?? [])")

let outputPipe = Pipe()
process.standardOutput = outputPipe

do {
    try process.run()
    print("? Process started successfully")
    process.waitUntilExit()
    print("? Process completed with status: \(process.terminationStatus)")
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    print("? Received \(outputData.count) bytes of data")
    
    if process.terminationStatus == 0 {
        // Successfully fetched data
        print("? Curl command executed successfully")
        
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
    } else {
        print("?? Command failed with status: \(process.terminationStatus)")
        if let errorOutput = String(data: outputData, encoding: .utf8) {
            print("?? Error output: \(errorOutput)")
        }
    }
} catch {
    print("?? Failed to run curl command: \(error)")
}

