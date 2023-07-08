import UIKit

private enum ETW: Error {
    case codeError
}

extension URLSession {
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let response = response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    completion(.failure(ETW.codeError))
                    return
                }
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(decodedData))
                    } catch let error {
                        completion(.failure(error))
                    }
                } else {
                    fatalError("Error")
                }
            }
        }
        return task
    }
}
