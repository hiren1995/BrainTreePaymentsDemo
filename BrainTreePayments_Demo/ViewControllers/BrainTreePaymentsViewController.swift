//
//  BrainTreePaymentsViewController.swift
//  BrainTreePayments_Demo
//
//  Created by LogicalWings Mac on 01/11/18.
//  Copyright © 2018 LogicalWings Mac. All rights reserved.
//

import UIKit
import Braintree
import BraintreeDropIn

class BrainTreePaymentsViewController: BaseViewController {

    @IBOutlet weak var txtAmount: UITextField!
    
    //sandbox_xx7bq9k6_rfpkd25wmmvpczdj
    
    let tokenizationKey = "sandbox_xx7bq9k6_rfpkd25wmmvpczdj"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Braintree Payments Demo"
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnTransfer(_ sender: UIButton) {
        
        // Test Values
        // Card Number: 4111111111111111
        // Expiration: 08/2018
        
        let request = BTDropInRequest()
        let dropIn = BTDropInController(authorization: tokenizationKey, request: request) {(controller, result, error) in
            
            if let error = error{
                print(error.localizedDescription)
            }
            else if (result?.isCancelled == true){
                print("Transaction Cancelled")
            }
            else if let nonce = result?.paymentMethod?.nonce , let amount = self.txtAmount.text{
                self.sendRequestPaymentToServer(nonce: nonce, amount: amount)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func sendRequestPaymentToServer(nonce: String, amount: String) {
        
        HttpManager.defaultManager.executeHttpRequest(apiRequest: .debitAPI(payment_method_nonce: nonce, amount: (amount as NSString).floatValue), apiCallbacks: self)
        
    }
    
    override func onHttpResponse(request: ApiRequest, data: Any) {
        
        let decoder = JSONDecoder()
        
        switch request {
        case .debitAPI:
            
            do{
                
                let response = try decoder.decode(DebitResponseModelBase.self, from: data as! Data)
                
                if response.success!{
                    
                    let alertView = UIAlertController(title: "Payment Status", message: "Transaction Successful", preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alertView, animated: true, completion: nil)
                }
                else{
                    self.serverResponseMessages("Transaction Failed")
                }
                
            }catch(let error){
                print(error)
            }
            break
        default:
            
            return
        }
    }

}
