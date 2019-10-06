//
//  Topic.swift
//  TinnoFeeds
//
//  Created by John Wong Chon Yong on 06/10/2019.
//  Copyright © 2019 TinnoLab. All rights reserved.
//

import Foundation

private let jsonFileValueDictionary:Dictionary<String,String> = ["Content-Type":"application/json", "Accept":"application/json"]
let getURL = "https://cryptic-shelf-48078.herokuapp.com/api/TinnoTopic/GetTopics"
let upVoteAPIURL = "https://cryptic-shelf-48078.herokuapp.com/api/TinnoTopic/UpVote"
let downVoteAPIURL = "https://cryptic-shelf-48078.herokuapp.com/api/TinnoTopic/DownVote"
let addTopicAPIURL = "https://cryptic-shelf-48078.herokuapp.com/api/TinnoTopic/AddTopic"


// Custom Error enum for easier error handling if a more complex error handling is needed
public enum CustomError: Error {
    case badURL
    case serverNotFound
    case badRequest(String?)
    case jsonConversionError
    case requestTimeOut
    case conflict(String?)
    case other(Error)
    case otherWithMsg(String?)
    
    init?(statusCode:Int, errorMsg:String?) {
        if statusCode == 400 {
            self = .badRequest(errorMsg)
        }
        else if statusCode == 404 {
            self = .serverNotFound
        }
        else if statusCode == 408 {
            self = .requestTimeOut
        }
        else if statusCode == 408 {
            self = .conflict(errorMsg)
        }
        else {
            self = .otherWithMsg(errorMsg)
        }
    }
}

// Topic object class
class Topic: NSObject {
    var id:String
    var title:String?
    var content:String?
    var createdBy:String?
    var upVote:Int = 0
    var downVote:Int = 0
    var createdDate:Date = Date()
    
    init(id:String) {
        self.id = id
        super.init()
    }
    
    init(dictionary:NSDictionary) throws {
        guard let id = dictionary["id"] as? String else {
            throw CustomError.otherWithMsg("Invalid data structure.")
        }
        self.id = id
        super.init()
        guard let title = dictionary["title"] as? String else {
            throw CustomError.otherWithMsg("Invalid data structure.")
        }
        guard let content = dictionary["content"] as? String else {
            throw CustomError.otherWithMsg("Invalid data structure.")
        }
        guard let createdBy = dictionary["createdBy"] as? String else {
            throw CustomError.otherWithMsg("Invalid data structure.")
        }
        guard let upVote = dictionary["upVote"] as? Int else {
            throw CustomError.otherWithMsg("Invalid data structure.")
        }
        guard let downVote = dictionary["downVote"] as? Int else {
            throw CustomError.otherWithMsg("Invalid data structure.")
        }
        
        var responseCreatedDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        if let dateString = dictionary["createdDate"] as? String {
            if let date = Date(jsonDate: dateString) {
                responseCreatedDate = date
            }
            else if let date = dateFormatter.date(from:dateString) {
                responseCreatedDate = date
            }
        }
        
        self.title = title
        self.content = content
        self.createdBy = createdBy
        self.upVote = upVote
        self.downVote = downVote
        self.createdDate = responseCreatedDate
    }
    
    //MARK: - Functions
    /** convert the user into a string format value */
    func toJSONString() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let UserAccountDictionary : [String:Any] =
            [
                "id": id,
                "title": title == nil ? "" : title!,
                "content": content == nil ? "" : content!,
                "createdBy": createdBy == nil ? "" : createdBy!,
                "upVote": upVote,
                "downVote": downVote,
                "CreatedDate": "\(dateFormatter.string(from: createdDate))"
        ]
        
        let jsonString = try! jsonStringify(value: UserAccountDictionary)
        
        return jsonString
    }
    
    /**
     serialize the object in parameter into json object
     - Parameters:
     - value: object to serialize.
     */
    private func jsonStringify(value: Any) throws -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions())
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                return string as String
            }
        }
        return ""
    }
}

//MARK: - URLSession Handler
extension Topic {
    
    /**
     Request top 20 topics from hosted server
     - Parameters:
     - postCompleted: completion handler with param -> Result<[Topic], Error>
     */
    class func getAllTopics(postCompleted : @escaping (Result<[Topic], Error>) -> Void) {
        guard let topicURL = URL(string: getURL) else {
            postCompleted(.failure(CustomError.badURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: topicURL) { (data, response, error) in
            guard error == nil else {
                postCompleted(.failure(error!))
                return
            }
            guard let responseData = data else {
                postCompleted(.failure(CustomError.otherWithMsg("Invalid response data.")))
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: .mutableLeaves) as? [Dictionary<String, Any>] else {
                    postCompleted(.failure(CustomError.jsonConversionError))
                    return
                }
                guard let topicsDictionaryArray = json as? [NSDictionary] else {
                    postCompleted(.failure(CustomError.otherWithMsg("Invalid response data.")))
                    return
                }
                var topicList = [Topic]()
                for topicDictionary in topicsDictionaryArray {
                    guard let _ = topicDictionary.object(forKey: "id") as? String else {
                        postCompleted(.failure(CustomError.otherWithMsg("Invalid response data.")))
                        return
                    }
                    topicList.append(try Topic(dictionary: topicDictionary))
                }
                postCompleted(.success(topicList))
            }
            catch let err as NSError {
                postCompleted(.failure(CustomError.other(err)))
            }
        }
        
        task.resume()
    }
    
    /**
     Add topic to hosted server
     - Parameters:
     - postCompleted: completion handler with param -> Result<Topic, Error>
     */
    func submitTopic(requestCompleted:@escaping (Result<Topic, Error>) -> Void) {
        let jsonString = self.toJSONString()
        let data = jsonString.data(using: String.Encoding.utf8)!
        
        post(bodyData: data, requestValue: jsonFileValueDictionary, urlString: addTopicAPIURL, timeOutInterval: 10.0) { (result) in
            switch result {
            case .success:
                requestCompleted(.success(self))
            case .failure(let error):
                requestCompleted(.failure(error))
            }
        }
    }
    
    /**
     increase the topic up vote by 1
     - Parameters:
     - postCompleted: completion handler with param -> Result<Topic, Error>
     */
    func upVoteTopic(requestCompleted:@escaping (Result<Topic, Error>) -> Void) {
        let jsonString = self.toJSONString()
        let data = jsonString.data(using: String.Encoding.utf8)!
        
        post(bodyData: data, requestValue: jsonFileValueDictionary, urlString: upVoteAPIURL, timeOutInterval: 10.0) { (result) in
            switch result {
            case .success:
                requestCompleted(.success(self))
            case .failure(let error):
                requestCompleted(.failure(error))
            }
        }
    }
    
    /**
     increase the topic down vote by 1
     - Parameters:
     - postCompleted: completion handler with param -> Result<Topic, Error>
     */
    func downVoteTopic(requestCompleted:@escaping (Result<Topic, Error>) -> Void) {
        let jsonString = self.toJSONString()
        let data = jsonString.data(using: String.Encoding.utf8)!
        
        post(bodyData: data, requestValue: jsonFileValueDictionary, urlString: downVoteAPIURL, timeOutInterval: 10.0) { (result) in
            switch result {
            case .success:
                requestCompleted(.success(self))
            case .failure(let error):
                requestCompleted(.failure(error))
            }
        }
    }
    
    
    /**
     Basic Post request
     - Parameters:
     - bodyData: data in json format.
     - requestValue: request body type dictionary.
     - urlString: The post request url.
     - timeOutInterval: interval time until timeout return.
     - postCompleted: Task Completion handler.
     */
    private func post(bodyData : Data, requestValue: [String:String]?, urlString : String, timeOutInterval:Double, postCompleted : @escaping (Result<[Dictionary<String,Any>], CustomError>) -> Void) {
        guard let url = URL(string: urlString) else {
            postCompleted(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = timeOutInterval
        sessionConfig.timeoutIntervalForResource = timeOutInterval
        let session = URLSession(configuration: sessionConfig)
        request.httpMethod = "POST"
        
        request.httpBody = bodyData
        if requestValue != nil {
            for (key,value) in requestValue! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            guard let httpResponse = response as? HTTPURLResponse else {
                guard let responseError = error else {
                    postCompleted(.failure(.badRequest(nil)))
                    return
                }
                postCompleted(.failure(.other(responseError)))
                return
            }
            switch(httpResponse.statusCode) {
            case 200, 201:
                guard let responseData = data else {
                    guard let responseError = error else {
                        postCompleted(.failure(.badRequest(nil)))
                        return
                    }
                    postCompleted(.failure(.other(responseError)))
                    return
                }
                do {
                    guard let json = try JSONSerialization.jsonObject(with: responseData, options: .mutableLeaves) as? [Dictionary<String, Any>] else {
                        postCompleted(.failure(.jsonConversionError))
                        return
                    }
                    postCompleted(.success(json))
                }
                catch let err as NSError {
                    postCompleted(.failure(.other(err)))
                }
                break
            default:
                guard let responseError = error else {
                    postCompleted(.failure(.badRequest(nil)))
                    return
                }
                guard let networkError = CustomError(statusCode: httpResponse.statusCode, errorMsg: responseError.localizedDescription) else {
                    postCompleted(.failure(.badRequest(nil)))
                    return
                }
                postCompleted(.failure(networkError))
            }
        })
        
        task.resume()
    }
}
