import Foundation

class PartyService {
    static let shared = PartyService()
    
    private let baseURL = URL(string: "http://0.0.0.0:3000")!
    
    func createInviteLink(partyId: String, completion: @escaping (URL?) -> Void) {
        let url = baseURL.appendingPathComponent("api/parties/\(partyId)/invite")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let link = json["inviteLink"] as? String {
                completion(URL(string: link))
            } else {
                // Mock link for now if server is not fully implemented
                completion(URL(string: "https://dreamroom.app/join/\(partyId)"))
            }
        }.resume()
    }
}
