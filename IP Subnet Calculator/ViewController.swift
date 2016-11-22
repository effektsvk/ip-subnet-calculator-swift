//
//  ViewController.swift
//  IP Subnet Calculator
//
//  Created by Erik Slovák on 09/11/2016.
//  Copyright © 2016 Erik Slovák. All rights reserved.
//

import UIKit

// Extensions for binary conversions
extension String {
    var binaryToInt: Int { return Int(strtoul(self, nil, 2)) }
}

extension Int {
    var binaryString: String { return String(self, radix: 2) }
}

extension String {
    var integerValue: Int { return Int(self) ?? 0 }
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var rawIPAddress: UITextField!
    @IBOutlet weak var rawSubnetMask: UITextField!
    
    @IBOutlet weak var labelErrorMessage: UILabel!
    @IBOutlet weak var labelSubnetBit: UILabel!
    @IBOutlet weak var labelNetworkClass: UILabel!
    @IBOutlet weak var labelStartHostAddress: UILabel!
    @IBOutlet weak var labelEndHostAddress: UILabel!
    @IBOutlet weak var labelMaxHosts: UILabel!
    @IBOutlet weak var labelNetworkAddress: UILabel!
    @IBOutlet weak var labelBroadcastAddress: UILabel!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func calculate(_ sender: Any) {
        
        
        self.view.endEditing(true)
        
        // Shows the maximum ammount of hosts
        // Max Hosts BEGIN
        var subnetMask = "N/A"
        var maxHosts: Int
        var result: [String] = ["", "", "", "", "", ""]
        var networkClass: String = "?"
        var errorMessage = ""
        let errorColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 0.6)
        let defaultColor = UIColor.clear
        
        if let subnetLabel = rawSubnetMask?.text {
            subnetMask = subnetLabel
        }
        
        switch subnetMask {
        case "255.255.255.252":
            labelMaxHosts.text = "2"
            labelSubnetBit.text = "/30"
            maxHosts = 2
        case "255.255.255.248":
            labelMaxHosts.text = "6"
            labelSubnetBit.text = "/29"
            maxHosts = 6
        case "255.255.255.240":
            labelMaxHosts.text = "14"
            labelSubnetBit.text = "/28"
            maxHosts = 14
        case "255.255.255.224":
            labelMaxHosts.text = "30"
            labelSubnetBit.text = "/27"
            maxHosts = 30
        case "255.255.255.192":
            labelMaxHosts.text = "62"
            labelSubnetBit.text = "/26"
            maxHosts = 62
        case "255.255.255.128":
            labelMaxHosts.text = "126"
            labelSubnetBit.text = "/25"
            maxHosts = 126
        case "255.255.255.0":
            labelMaxHosts.text = "254"
            labelSubnetBit.text = "/24"
            maxHosts = 254
        case "255.255.254.0":
            labelMaxHosts.text = "510"
            labelSubnetBit.text = "/23"
            maxHosts = 510
        case "255.255.252.0":
            labelMaxHosts.text = "1022"
            labelSubnetBit.text = "/22"
            maxHosts = 1022
        case "255.255.248.0":
            labelMaxHosts.text = "2046"
            labelSubnetBit.text = "/21"
            maxHosts = 2046
        case "255.255.240.0":
            labelMaxHosts.text = "4094"
            labelSubnetBit.text = "/20"
            maxHosts = 4094
        case "255.255.224.0":
            labelMaxHosts.text = "8190"
            labelSubnetBit.text = "/19"
            maxHosts = 8190
        case "255.255.192.0":
            labelMaxHosts.text = "16382"
            labelSubnetBit.text = "/18"
            maxHosts = 16382
        case "255.255.128.0":
            labelMaxHosts.text = "32766"
            labelSubnetBit.text = "/17"
            maxHosts = 32766
        case "255.255.0.0":
            labelMaxHosts.text = "65534"
            labelSubnetBit.text = "/16"
            maxHosts = 65534
        default:
            labelMaxHosts.text = "N/A"
            labelSubnetBit.text = ""
        }
        // Max Hosts END
        
        // Converts to binary array
        // Binary BEGIN
        
        func calculatePressed() -> [String] { // returns result array
            
            func fill(a: String) -> String { // Fills zeros at the begining for the AND/OR processes
                var result = a
                while result.characters.count < 8 {
                    result.insert("0", at: result.startIndex)
                }
                return result
            }
            
            func reverse() -> [String] { // Reverses the subnet mask for OR (broadcast address) process
                
                var reversedSubnet: [String] = ["", "", "", ""]
                var part = 0
                
                let binarySubnet = convert(address: rawSubnetMask.text)
                
                while part < 4 {
                    
                    let numberSubnet: String = binarySubnet[part]
                    var i = 0
                    
                    while i < 8 {
                        let indexSubnet = numberSubnet.index(numberSubnet.startIndex, offsetBy: i)
                        
                        if intToBool(num: Int(numberSubnet[indexSubnet].description)) {
                            reversedSubnet[part].append("0")
                        } else {
                            reversedSubnet[part].append("1")
                        }
                    
                        i += 1
                    }
                
                    part += 1
                }
                
                return reversedSubnet
                
            }
            
        
            func convertFromBinary(array: [String]) -> String { // Converts from binary to usable String (e.g. "192.168.1.1")
                
                var result: String = ""
                var i = 0
                while i < 4 {
                    
                    result.append(String(array[i].binaryToInt))
                    if i < 3 {
                        result.append(".")
                    }
                    
                    i += 1
                }
                
                return result
                
            }
            
            func intToBool(num: Int?) -> Bool { // converts from binary Int to Bool
                var result: Bool
                if num == 0 {
                    result = false
                } else {
                    result = true
                }
                return result
            }
            
            func rawToString(address: String?) -> String { // 1. - Unwraps text field
                
                var output = "0"
                if let unwrapped = address {
                    output = unwrapped
                }
                if output.isEmpty {
                    errorMessage = "One of the text fields is empty. Check your input and try again."
                    rawIPAddress.backgroundColor = errorColor
                    rawSubnetMask.backgroundColor = errorColor
                }
                return output
            }
            
            func fetchFromString(address: String) -> [Int] { // 2. - Fetching from string to Int array
                
                var intArray: [Int]
                if !address.contains(".") {
                    intArray = [0, 0, 0, 0]
                    result[5] = "One of your addresses does not contain a period \".\""
                    rawIPAddress.backgroundColor = errorColor
                    rawSubnetMask.backgroundColor = errorColor
                } else {
                    let rawArray = address.components(separatedBy: ".")
                    intArray = rawArray.map { $0.integerValue }
                    if intArray.count < 4 {
                        intArray = [0, 0, 0, 0]
                        errorMessage = "One (or both) of your addresses is not long enough."
                        rawIPAddress.backgroundColor = errorColor
                        rawSubnetMask.backgroundColor = errorColor
                    }
                }
                return intArray
                
            }
            
            
            func convertToBinary(array: [Int]) -> [String] { // 3. - Converting Int array to Binary String array
                
                var binaryArray: [String] = []
                var i = 0
                
                while i < 4 {
                    let part = array[i].binaryString
                    let fixedPart = fill(a: part)
                    binaryArray.insert(fixedPart, at: (i))
                    i += 1
                }
                
                return binaryArray
                
            }
            
            func convert(address: String?) -> [String] { // returns binary address
                
                return convertToBinary(array: fetchFromString(address: rawToString(address: address)))
                
            }
            
            // Binary END
            
            // Network Address calculation (AND)
            
            // Network BEGIN
            
            let binaryIP = convert(address: rawIPAddress.text)
            let binarySubnet = convert(address: rawSubnetMask.text)
            
            func networkAddress() -> String { // returns usable network address
                
                var networkAddress: [String] = ["", "", "", ""]
                
                var part = 0
                
                while part < 4 { // breaking down the array
                    
                    let numberIP: String = binaryIP[part]
                    let numberSubnet: String = binarySubnet[part]
                    
                    var i = 0
                    
                    while i < 8 {
                        let indexIP = numberIP.index(numberIP.startIndex, offsetBy: i)
                        let indexSubnet = numberSubnet.index(numberSubnet.startIndex, offsetBy: i)
                        
                        if intToBool(num: Int(numberIP[indexIP].description)) && intToBool(num: Int(numberSubnet[indexSubnet].description)) {
                            networkAddress[part].append("1")
                            
                        } else {
                            networkAddress[part].append("0")
                        }
                        
                        i += 1
                    }
                    
                    part += 1
                }
                
                
                return convertFromBinary(array: networkAddress)
            }
            
            // Network END
            
            // Broadcast Address calculation (OR)
            
            // Broadcast BEGIN
            
            func broadcastAddress() -> String {
                
                
                let reversedSubnet = reverse()
                var broadcastAddress: [String] = ["", "", "", ""]
                
                var part = 0
                
                while part < 4 {
                
                    let numberSubnet: String = reversedSubnet[part]
                    let numberIP: String = binaryIP[part]
                    
                    var i = 0
                    
                    while i < 8 {
                        let indexIP = numberIP.index(numberIP.startIndex, offsetBy: i)
                        let indexSubnet = numberSubnet.index(numberSubnet.startIndex, offsetBy: i)
                 
                        if intToBool(num: Int(numberIP[indexIP].description)) || intToBool(num: Int(numberSubnet[indexSubnet].description)) {
                            broadcastAddress[part].append("1")
                            
                        } else {
                            broadcastAddress[part].append("0")
                        }
                        
                        i += 1
                    }
                
                    
                part += 1
                }
                
                return convertFromBinary(array: broadcastAddress)
            }
            
            // Broadcast END
            
            // Start and End Host Address Calculation
            
            // Start and End Address BEGIN
            
            func startHostAddress() -> String {
                
                var intArray: [Int] = fetchFromString(address: networkAddress())
                
                if intArray[3] < 256 {
                    intArray[3] += 1
                } else {
                    intArray[2] += 1
                    intArray[3] = 0
                }
                
                return convertFromBinary(array: convertToBinary(array: intArray))
                
            }
            
            func endHostAddress() -> String {
                
                var intArray: [Int] = fetchFromString(address: broadcastAddress())
                
                if intArray[3] < 0 {
                    intArray[2] -= 1
                    intArray[3] = 255
                } else {
                    intArray[3] -= 1
                }
                
                return convertFromBinary(array: convertToBinary(array: intArray))
            }
            
            // Start and End Address END
            
            // Checks if it is possible to calculate + determines the Network Class
            
            // Class BEGIN
            
            var ipAddress = fetchFromString(address: rawToString(address: rawIPAddress.text))
            
            switch ipAddress[0] {
            case 1...126:
                networkClass = "A"
                errorMessage = ""
            case 127:
                networkClass = "N/A"
                errorMessage = "IP adresses of type 127.x.x.x are reserved for loopback."
                rawIPAddress.backgroundColor = errorColor
            case 128...191:
                networkClass = "B"
                errorMessage = ""
            case 192...223:
                networkClass = "C"
                errorMessage = ""
            case 224...239:
                networkClass = "D"
                errorMessage = "Class D is reserved for multicasting, therefore there's no need to extract host address and Class D doesn't have any subnet mask."
                rawIPAddress.backgroundColor = errorColor
            case 240...255:
                networkClass = "E"
                errorMessage = "Class E is reserved for experimental purposes and therefore it's not equipped with any subnet mask."
                rawIPAddress.backgroundColor = errorColor
            default:
                networkClass = "N/A"
                errorMessage = "Unknown error. Please, double check your input."
                rawIPAddress.backgroundColor = errorColor
                rawSubnetMask.backgroundColor = errorColor
            }
            
            // Class END
        
            // Result BEGIN
            if (networkClass == "A" || networkClass == "B" || networkClass == "C"){
                result = [startHostAddress(), endHostAddress(), networkAddress(), broadcastAddress(), networkClass, errorMessage] // [0 - Start Host Address, 1 - End Host Address, 2 - Network Address, 3 - Broadcast Address, 4 - Network Class, 5 - Error Message]
                rawIPAddress.backgroundColor = defaultColor
                rawSubnetMask.backgroundColor = defaultColor
                if !errorMessage.isEmpty {
                    rawIPAddress.backgroundColor = errorColor
                    rawSubnetMask.backgroundColor = errorColor
                }
            } else {
                result = ["N/A", "N/A", "N/A", "N/A", networkClass, errorMessage]
                rawIPAddress.backgroundColor = errorColor
                rawSubnetMask.backgroundColor = errorColor
            }
            // Result END
            
            return result
            
            } // func calculatePressed() end
        
        result = calculatePressed()
        
        labelStartHostAddress.text = result[0]
        labelEndHostAddress.text = result[1]
        labelNetworkAddress.text = result[2]
        labelBroadcastAddress.text = result[3]
        labelNetworkClass.text = result[4]
        labelErrorMessage.text = result[5]
        } // calculate (button pressed) end
        
            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

