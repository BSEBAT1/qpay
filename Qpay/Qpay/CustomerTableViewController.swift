//
//  CustomerTableViewController.swift
//  Qpay
//
//  Created by Berkay Sebat on 3/30/20.
//  Copyright © 2020 QPAY. All rights reserved.
//

import UIKit

@objc class CustomerTableViewController: ViewController {

    @IBOutlet var customerAccountsTableView: UITableView!
    @objc var customerData = [CustomerDataObj]()
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    private let urlBase = "http://58d19028.ngrok.io"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customerAccountsTableView.delegate = self
        self.customerAccountsTableView.dataSource = self
        customerAccountsTableView.tableFooterView = UIView()
    }
}

extension CustomerTableViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = customerData[indexPath.row]
        let tableViewCell = UITableViewCell.init()
        tableViewCell.textLabel?.text = title.name
        return tableViewCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Please Select An Account For Debits"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCustomer = customerData[indexPath.row]
        dataTask?.cancel()
        guard let url = URL.init(string: urlBase+"/get_access_token") else {return}
        //[NSString stringWithFormat:@"public_token=%@&account_id=%@",publicToken,account_id];
        let bodyString = "public_token=\(selectedCustomer.publicToken!)"+"&"+"account_id=\(selectedCustomer.accountId!)"
        
        // Prepare URL Request Object
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        
        // Set HTTP Request Body
        request.httpBody = bodyString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
            
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                   
                }
        }
        task.resume()
    }
}
