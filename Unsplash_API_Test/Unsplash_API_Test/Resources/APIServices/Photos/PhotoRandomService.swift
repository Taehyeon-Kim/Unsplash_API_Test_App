//
//  PhotoRandomService.swift
//  Unsplash_API_Test
//
//  Created by taehy.k on 2021/02/15.
//

import Foundation

import Alamofire

struct PhotoRandomService {
    static let shared = PhotoRandomService()
    
    func makeURL(clientID: String, count: String) -> String {
        var url = APIConstants.randomPhotoURL
        url = url.replacingOccurrences(of: "{client_id}", with: clientID)
        url = url.replacingOccurrences(of: "{count}", with: count)

        return url
    }
    
    func getRandomPhoto(clientID: String, count: String, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        let url = makeURL(clientID: clientID, count: count)
        let dataRequest = AF.request(url, method: .get, encoding: JSONEncoding.default)

        dataRequest.responseData{ (response) in
            switch response.result{
                case .success:
                    guard let statusCode = response.response?.statusCode else{
                        return
                    }
                    guard let data = response.value else{
                        return
                    }
                    completion(judgeRandomPhoto(status: statusCode, data: data, url: url))
                case .failure(let err):
                    print(err)
                    completion(.networkFail)
            }
        }
    }
    
    private func judgeRandomPhoto(status: Int, data: Data, url: String) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode([Result].self, from: data) else{
            return .pathErr
        }
        switch status{
            case 200:
                return .success(decodedData)
            case 400..<500:
                return .requestErr(decodedData)
            case 500:
                return .serverErr
            default:
                return .networkFail
        }
    }
}
