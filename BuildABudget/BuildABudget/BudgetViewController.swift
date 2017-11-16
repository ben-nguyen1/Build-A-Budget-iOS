//
//  BudgetViewController.swift
//  BuildABudget
//
//  Created by chris on 10/24/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//
protocol MoneyDelegate {
    
    func isValidAmount( inputMoneyString: String ) -> Bool
}


import UIKit
import Foundation

class BudgetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    
    
    
    @IBAction func addIncomeButton(_ sender: Any) {
        addIncome()
    }
    
    @IBAction func addExpenseButton(_ sender: Any) {
        addExpense()
    }
    
    @IBOutlet weak var incomeTable: UITableView! //has attribute .tag = 111
    @IBOutlet weak var expenseTable: UITableView! //has attribute .tag = 222
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    
    fileprivate var incomeList: [MyTransaction] = []
    fileprivate var expenseList: [MyTransaction] = []
    fileprivate var thisBudget: MyBudget? = nil
    
    var incomeTotal:Double = 0.0
    var expenseTotal:Double = 0.0
    var differenceAmount = 0.0
    
    //UIAlert field vars
    var descriptionTextField: UITextField? = nil
    var dueDateTextField: UITextField? = nil
    var totalDueTextField: UITextField? = nil //Double? = nil
    
    //var with ability to interface with the coreData storage methods
    var BudgetAccess = AccessService.access
    let thisDate = MyDate.dateConverter
    
    //var dueDatePicker
    let dueDatePicker = UIDatePicker()
    
    //Set custom colors
    let moneyPositiveColor = UIColor(red:0.32, green:0.64, blue:0.33, alpha:1.0)    //hex: 0x51A453
    let textFieldErrorColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0) //hex: FF0000
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        thisBudget = BudgetAccess.getBudget(index: 0) //for right now it is hard coded to only get the first budget, we might allow users to save multiple budgets later on.
        self.update()
    }
    
    //return number of rows for a specific tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 111{//incomeTable
            print("incomeList = \(incomeList.count)")
            return incomeList.count //+ 1
        }
        else if tableView.tag == 222{//expenseTable
            print("expenseList = \(expenseList.count)")
            return expenseList.count //+ 1
        }
        else {
            return 0 //catches tableview tags that are not incomeTable or expenseTable tags
        }
    }
    
    //populate each table with TableViewCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == self.incomeTable){//tableView.tag == 111    incomeTable
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetLineCell", for: indexPath) as! BudgetLineCell
            //set up the cell
            let shortDate = thisDate.shortDateToString(inputDate: (incomeList[indexPath.item].dueDate) )
            cell.config(inputName: incomeList[indexPath.item].desciption, inputDate: shortDate, inputAmount: incomeList[indexPath.item].totalDue.description) //may need to chnage how to parameters dueDate and amount are converted to string.
            
            
            cell.inViewTable = 111
            return cell
        }
        else {//expenseTable
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetExpenseCell", for: indexPath) as! BudgetExpenseCell
            //set up the cell
            let shortDate = thisDate.shortDateToString(inputDate: (expenseList[indexPath.item].dueDate) )
            cell.config(inputName: expenseList[indexPath.item].desciption, inputDate: shortDate, inputAmount: expenseList[indexPath.item].totalDue.description) //may need to chnage how to parameters dueDate and amount are converted to string.
            cell.inViewTable = 222
            return cell
        }
    }
    
    //UIAlert window that allows user to input the Description, Amount, and Due Date of their new expense or income
    func launchAlertWindow(tableValueInput: Int) {
        
        var alertWindowTitle:   String = ""
        var description:        String = ""
        var dueDate:            Date? = nil
        var totalDue:           Double = 0.0
        var isIncome:           Bool = false //only changed if add button from incomeTable is pressed
        
        //set title of window accordingly
        if tableValueInput == 111 {// 111 means we are in the incomeTable
            alertWindowTitle = "New Monthly Income"
            isIncome = true
        }
        else {// this means that our inViewTable tag is 222 and we are in the expenseTable
            alertWindowTitle = "New Monthly Expense"
        }
        
        //set the AlertWindow's title and instruction message to user
        let newBudgetLineInputWindow = UIAlertController(title: alertWindowTitle, message: "Fill out all fields", preferredStyle: .alert)
        
        //do not change the order of these three .addTextFields
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Item Description"
            self.descriptionTextField = textField
            
            /*
             textField.layer.borderWidth = 1
             textField.layer.borderColor = UIColor.whiteColor().CGColor
             */
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Amount ex: 32.49"
            self.totalDueTextField = textField
            //self.totalDueTextField?.backgroundColor = UIColor.blue <----- experimented with background colors (future use)
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Due Date ex: 01/09/2017"
            self.dueDateTextField = textField
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction!) -> Void in
            
            //grab all the data from the alert window's text fields
            guard let descriptionTextField = self.descriptionTextField?.text, self.isValidDescription(input: (self.descriptionTextField?.text)!) else {
                print("<<<<<< HERE >>>>>")
                return }
            guard let totalDueTextField = self.totalDueTextField?.text else { return }
            guard let dueDateTextField = self.dueDateTextField?.text else { return }
            
            //set the data that we grabbed into local variables
            description = descriptionTextField
            dueDate = MyDate.dateConverter.stringToDate(inputString: dueDateTextField)
            totalDue = (totalDueTextField as NSString).doubleValue
            
            //Build the MyTransaction Object
            let newBudgetItem = MyTransaction.create( iDes: description,
                                                      iIniDate: Date(),
                                                      iDueDate: dueDate!,
                                                      iDatePaidOff: MyDate.dateConverter.setToYesterday(today: Date()),
                                                      iTotalDue: totalDue,
                                                      iIsReoccuring: true,
                                                      iIsIncome: isIncome)
            
            //save the MyTransaction Object to CoreData
            AccessService.access.saveTransaction(input: newBudgetItem)
            
            self.update()
            print("\n\nFinished Saving a new BudgetLineItem")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (action: UIAlertAction!) -> Void in
        }
        
        //add the buttons to the Alert window
        newBudgetLineInputWindow.addAction(saveAction)
        newBudgetLineInputWindow.addAction(cancelAction)
        
        //display the alert window on the screen
        present(newBudgetLineInputWindow, animated: true, completion: nil)
    }
    
    //UIAlert window input validation methods
    func isValidDescription( input:String) -> Bool{
        if  !input.isEmpty {//basically any charactes will do as long as something is input
            return true
        }
        else {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set each table's data source
        incomeTable.dataSource = self
        expenseTable.dataSource = self
        
        //set each table's delegate
        incomeTable.delegate = self
        expenseTable.delegate = self
        
        navigationItem.title = "Budget"
        print("IN BUDGET")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //update incomeList, expenseList, incomeTotal, expenseTotal
    func update(){
        
        BudgetAccess.retreiveAllTransactions()//cause all transactions to be reloaded by CoreDate interface
        
        //set all lists and counters to 0
        incomeList = []
        expenseList = []
        incomeTotal = 0.0
        expenseTotal = 0.0
        
        var i = 0
        var limit = BudgetAccess.totalTransactions()
        for i in 0..<limit {
            let temp = BudgetAccess.getTransaction(index: i)
            if temp.isIncome {
                incomeList.append(temp)
                incomeTotal += temp.totalDue
                print("incomeTotal = \(incomeTotal)")
            }
            else {
                expenseList.append(temp)
                expenseTotal += temp.totalDue
                print("expenseTotal = \(expenseTotal)")
            }
        }
        
        //calculate the budget deficit/surplus
        differenceAmount = incomeTotal - expenseTotal
        
        //display the incomeTotal, expenseTotal, differenceAmount on view controller
        self.incomeLabel.text = String(format: "$   %.2F", incomeTotal)
        self.expenseLabel.text = String(format: "$ -%.2F", expenseTotal)
        self.differenceLabel.text = String(format: "$   %.2F", differenceAmount)
        
        //change differenceLabel text color if value is positive or negative
        if differenceAmount >= 0.0 {
            self.differenceLabel.textColor = moneyPositiveColor //= UIColor(red:0.32, green:0.64, blue:0.33, alpha:1.0)
            self.differenceLabel.text = String(format: "$   %.2F", differenceAmount)
        }
        else {
            self.differenceLabel.textColor = UIColor.red
            self.differenceLabel.text = String(format: "$ %.2F", differenceAmount)
        }
        
        //reload the UITables to display the new transaction data
        self.incomeTable.reloadData()
        self.expenseTable.reloadData()
    }
    
    func addIncome() {
        
        var alertWindowTitle:   String = "Add Income"
        var description:        String = ""
        var dueDate:            Date? = nil
        var totalDue:           Double = 0.0
        var isIncome:           Bool = true //only changed if add button from incomeTable is pressed
        
        //set the AlertWindow's title and instruction message to user
        let newBudgetLineInputWindow = UIAlertController(title: alertWindowTitle, message: "Fill out all fields", preferredStyle: .alert)
        
        //do not change the order of these three .addTextFields
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Item Description"
            self.descriptionTextField = textField
            //self.descriptionTextField?.layer.borderColor = (UIColor.red).cgColor <--- these two lines are how we let user know they goofed.
            //self.descriptionTextField?.layer.borderWidth = 1.0
            //self.descriptionTextField?.layer.borderWidth =
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Amount ex: 32.49"
            self.totalDueTextField = textField
            self.totalDueTextField?.keyboardType = UIKeyboardType.decimalPad
            //self.totalDueTextField?.backgroundColor = UIColor.blue <----- experimented with background colors (future use)
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Due Date ex: 01/09/2017"
            self.dueDateTextField = textField
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction!) -> Void in
            
            //grab all the data from the alert window's text fields
            guard let descriptionTextField = self.descriptionTextField?.text, self.isValidDescription(input: (self.descriptionTextField?.text)!) else {
                return }
            guard let totalDueTextField = self.totalDueTextField?.text else { return }
            guard let dueDateTextField = self.dueDateTextField?.text else { return }
            
            //set the data that we grabbed into local variables
            description = descriptionTextField
            dueDate = MyDate.dateConverter.stringToDate(inputString: dueDateTextField)
            totalDue = (totalDueTextField as NSString).doubleValue
            
            //Build the MyTransaction Object
            let newBudgetItem = MyTransaction.create( iDes: description,
                                                      iIniDate: Date(),
                                                      iDueDate: dueDate!,
                                                      iDatePaidOff: MyDate.dateConverter.setToYesterday(today: Date()),
                                                      iTotalDue: totalDue,
                                                      iIsReoccuring: true,
                                                      iIsIncome: isIncome)
            
            //save the MyTransaction Object to CoreData
            AccessService.access.saveTransaction(input: newBudgetItem)
            
            self.update()
            print("\n\nFinished Saving a new BudgetLineItem")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (action: UIAlertAction!) -> Void in
        }
        
        //add the buttons to the Alert window
        newBudgetLineInputWindow.addAction(saveAction)
        newBudgetLineInputWindow.addAction(cancelAction)
        
        //display the alert window on the screen
        present(newBudgetLineInputWindow, animated: true, completion: nil)
        
        showDatePickerKeyboard(textField: dueDateTextField!)
    }
    
    
    
    
    
    
    func addExpense() {
        
        var alertWindowTitle:   String = "Add Income"
        var description:        String = ""
        var dueDate:            Date? = nil
        var totalDue:           Double = 0.0
        var isIncome:           Bool = false //only changed if add button from incomeTable is pressed
        
        //set the AlertWindow's title and instruction message to user
        let newBudgetLineInputWindow = UIAlertController(title: alertWindowTitle, message: "Fill out all fields", preferredStyle: .alert)
        
        //do not change the order of these three .addTextFields
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Item Description"
            self.descriptionTextField = textField
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Amount ex: 32.49"
            self.totalDueTextField = textField
            self.totalDueTextField?.keyboardType = UIKeyboardType.decimalPad
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Due Date ex: 01/09/2017"
            self.dueDateTextField = textField
        }
        
        
        
        
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction!) -> Void in
            
            //grab all the data from the alert window's text fields
            guard let descriptionTextField = self.descriptionTextField?.text, self.isValidDescription(input: (self.descriptionTextField?.text)!) else {
                
                self.descriptionTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.descriptionTextField?.layer.borderWidth = 1.0
                return
            }
            
            guard let totalDueTextField = self.totalDueTextField?.text, self.isValidAmount(inputMoneyString: (self.totalDueTextField?.text)! ) else {
                
                self.descriptionTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.descriptionTextField?.layer.borderWidth = 1.0
                return
            }
            
            guard let dueDateTextField = self.dueDateTextField?.text else {
                
                self.descriptionTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.descriptionTextField?.layer.borderWidth = 1.0
                return
            }
            
            //set the data that we grabbed into local variables
            description = descriptionTextField
            dueDate = MyDate.dateConverter.stringToDate(inputString: dueDateTextField)
            totalDue = (totalDueTextField as NSString).doubleValue
            
            //Build the MyTransaction Object
            let newBudgetItem = MyTransaction.create( iDes:             description,
                                                      iIniDate:         Date(),
                                                      iDueDate:         dueDate!,
                                                      iDatePaidOff:     MyDate.dateConverter.setToYesterday(today: Date()),
                                                      iTotalDue:        totalDue,
                                                      iIsReoccuring:    true,
                                                      iIsIncome:        isIncome)
            
            //save the MyTransaction Object to CoreData
            AccessService.access.saveTransaction(input: newBudgetItem)
            
            self.update()
            print("\n\nFinished Saving a new BudgetLineItem")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (action: UIAlertAction!) -> Void in
        }
        
        //add the buttons to the Alert window
        newBudgetLineInputWindow.addAction(saveAction)
        newBudgetLineInputWindow.addAction(cancelAction)
        
        showDatePickerKeyboard(textField: dueDateTextField!)
        //display the alert window on the screen
        present(newBudgetLineInputWindow, animated: true, completion: nil)
    }
    
    
    
    
    
    
    //swipe to delete functionality
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        print("income count = \(self.incomeList.count)\texpense count = \(self.incomeList.count)")
        if (tableView == self.incomeTable) {
            
            let removeIncome = UITableViewRowAction(style: .normal, title: "Delete") {action, index in
                
                let removedTransaction = self.incomeList[index.row]
                
                self.BudgetAccess.deleteTransaction(input: removedTransaction)
                self.update()
                print(">>>REMOVED INCOME TRANSACTION\(index.row)\tnew income count = \(self.incomeList.count)")
            }
            removeIncome.backgroundColor = UIColor.red
            return [removeIncome]
        }
        else {
            let removeExpense = UITableViewRowAction(style: .normal, title: "Delete") {
                action, index in
                self.BudgetAccess.deleteTransaction(input: self.expenseList[index.row])
                self.update()
                print(">>>REMOVED EXPENSE TRANSACTION\(index.row)\tnew income count = \(self.expenseList.count)")
            }
            removeExpense.backgroundColor = UIColor.red
            return [removeExpense]
        }
    }
    
    
    //Displays UIDatePicker upon text field selection.
    func showDatePickerKeyboard(textField: UITextField) {
        if textField == dueDateTextField {//set the text field that should display the UIDatePicker
            let myDatePicker = UIDatePicker()
            myDatePicker.datePickerMode = .date
            textField.inputView = myDatePicker
            myDatePicker.addTarget(self, action: #selector(setSelectedDate(sender: )), for: .valueChanged) //this sends the currently selected date at every instance that user pauses to the setSelectedDate(sender: UIDatePicker) method
        }
    }
    
    //this func sets each input passed to it to a string and sets the dueDateTextField to the resulting string
    func setSelectedDate(sender: UIDatePicker) {
        dueDateTextField?.text = thisDate.dateToString(inputDate: (sender.date))
    }
    
    //check if input amount is valid
    /*
     func amountIsValid( inputAmount: String) -> Bool {
     
     let dollarAmountRegex : String = "(\d{1,9})\.(\d{1,2})"
     return self.rangeOfStringrangeOfString(dollarAmountRegex, options: .RegularExpressionSearch) != nil
     }
     //([0-9]\d{0,9})\.([0-9]\d{0,2})
     return false
     }
     */
    
    //check if input amount is valid
    func isValidAmount(inputMoney: Double) -> Bool {
        
        //conditions on money:
        //
        //1. the amount input by the user must be: 0.00 <= x <= 1,000,000,000.00 <- this range is set to adhere to our 13 char cell text space limit for money amounts
        //
        //2. the amount can only have digits 0-9 and can only have up to 1 "."
        //
        //regex = (\d{1,9})(\.{0,1})(\d{0,2})
        
        return true
    }
    
    //check if input amount is valid
    func isValidAmount(inputMoneyString: String) -> Bool {
        
        //conditions on money:
        //
        //1. the amount input by the user must be: 0.00 <= x <= 1,000,000,000.00 <- this range is set to adhere to our 13 char cell text space limit for money amounts
        //
        //2. the amount can only have digits 0-9 and can only have up to 1 "."
        //
        //regex = (\d{1,9})(\.{0,1})(\d{0,2})
        
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 'First Responder' is the same as 'input focus'.
        // We are removing input focus from the text field.
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user touches on the main view (outside the UITextField).
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}//end of BudgetViewController class



























