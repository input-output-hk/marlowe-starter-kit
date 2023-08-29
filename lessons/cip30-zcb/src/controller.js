/* Example of Using Marlowe Runtime with a CIP30 Wallet */


'use strict'


// Use a Bech32 library for converting address formats.

import {bech32} from "bech32"

export const b32 = bech32


// Connection to the CIP30 wallet.
var wallet = null

// Address of the lender.
var address = null

// Identifier for the contract.
var contractId = null

// URL for Marlowe Runtime's /contracts endpoint.
var contractUrl = null

// URL for Marlowe Runtime's /contract/*/transactions endpoint.
var transactionUrl = null

// The JSON for the Marlowe contract.
var contract = {}

// Poll every five seconds.
const delay = 5000

// One ada is one million lovelace.
const ada = 1000000


/**
 * Set the wallet's address in the UI.
 * @param [String] a The hexadecimal bytes for the address.
 */
function setAddress(a) {
  const bytes = []
  for (let c = 0; c < a.length; c += 2)
    bytes.push(parseInt(a.substr(c, 2), 16))
  address = bech32.encode("addr_test", bech32.toWords(bytes), 1000)
//const display = address.substr(0, 20) + "..." + address.substr(address.length - 15)
//uiLender.innerHTML = "<a href='https://preprod.cardanoscan.io/address/" + a + "' target='marlowe'>" + display + "</a>"
  uiLender.value = address
}


/**
 * Set the contract ID in the UI.
 * @param [String] c The contract ID.
 */
function setContract(c) {
  contractId = c
  uiContractId.innerHTML = "<a href='https://preprod.marlowescan.com/contractView?tab=info&contractId=" + contractId.replace("#", "%23") + "' target='marlowe'>" + contractId + "</a>"
}


/**
 * Set a link to a transaction in the UI.
 * @param [Element] element The UI element for the transaction.
 * @param [String]  tx      The transaction ID.
 */
function setTx(element, tx) {
  const display = tx.substr(0, 18) + "..." + tx.substr(tx.length - 18)
  element.innerHTML = "<a href='https://preprod.cardanoscan.io/transaction/" + tx + "?tab=utxo' target='marlowe'>" + display + "</a>"
}


/**
 * Make the JSON for the Marlowe contract.
 */
export function makeContract() {
  const principal = parseInt(uiPrincipal.value)
  const interest = parseInt(uiInterest.value)
  const loanDeadline = Date.parse(uiLoanDeadline.value)
  const paybackDeadline = Date.parse(uiPaybackDeadline.value)
  contract = {
    when: [
      {
        case: {
          party: { role_token: "Lender" },
          deposits: principal,
          of_token: { token_name: "", currency_symbol: "" },
          into_account: { role_token: "Lender" }
        },
        then: {
          pay: principal,
          token: { token_name: "", currency_symbol: "" },
          from_account: { role_token: "Lender" },
          to: { party: { role_token: "Borrower" } },
          then: {
            when: [
              {
                case: {
                  party: { role_token: "Borrower" },
                  deposits: { and: principal, add: interest },
                  of_token: { token_name: "", currency_symbol: "" },
                  into_account: { role_token: "Borrower" }
                },
                then: {
                  pay: { and: principal, add: interest },
                  token: { token_name: "", currency_symbol: "" },
                  from_account: { role_token: "Borrower" },
                  to: { party: { role_token: "Lender" } },
                  then: "close"
                }
              }
            ],
            timeout_continuation: "close",
            timeout: paybackDeadline
          },
        }
      }
    ],
    timeout_continuation: "close",
    timeout: loanDeadline
  }
  console.log({contract : contract})
  uiContract.replaceChildren(window.renderjson.set_show_to_level(10)(contract))
}


/**
 * Perform an operation that requires blocking the UI.
 */
function waitCursor() {
  document.body.style.cursor = "wait"
  uiCreate.style.cursor = "wait"
  uiLoan.style.cursor = "wait"
  uiWithdrawLoan.style.cursor = "wait"
  uiPayback.style.cursor = "wait"
  uiWithdrawPayback.style.cursor = "wait"
  uiMessage.innerText = "Working . . ."
}


/**
 * Report a result and unblock the UI.
 */
function report(message) {
  document.body.style.cursor = "default"
  uiCreate.style.cursor = "default"
  uiLoan.style.cursor = "default"
  uiWithdrawLoan.style.cursor = "default"
  uiPayback.style.cursor = "default"
  uiWithdrawPayback.style.cursor = "default"
  status(message)
}


/**
 * Show a status message in the UI.
 * @param [String] message The message.
 */
function status(message) {
  uiMessage.innerText = message
}


/**
 * Build a Marlowe transaction.
 * @param [String]   operation The name of the operation being performed.
 * @param [Object]   req       The HTTP request.
 * @param [String]   url       The endpoint's URL.
 * @param [String]   accept    The "accept" HTTP header.
 * @param [Function] followup  Actions to perform after the transaction is built.
 */
async function buildTransaction(operation, req, url, accept, followup) {
  waitCursor()
  const xhttp = new XMLHttpRequest()
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4) {
      console.log({operation : operation, status : this.status, response : this.responseText})
      if (this.status == 201) {
        const res = JSON.parse(this.responseText)
        followup(res)
      } else {
        report("Transaction building failed.")
      }
    }
  }
  xhttp.open("POST", url)
  xhttp.setRequestHeader("Content-Type", "application/json")
  xhttp.setRequestHeader("Accept", accept)
  xhttp.setRequestHeader("X-Change-Address", address)
  console.log({operation : operation, request : req})
  status("Building transaction.")
  xhttp.send(JSON.stringify(req))
}


/**
 * Create the contract.
 */
export async function createContract() {
  buildTransaction(
    "create"
  , {
      version : "v1"
    , contract : contract
    , roles : {
        "Lender" : uiLender.value
      , "Borrower" : uiBorrower.value
      }
    , minUTxODeposit : 2 * ada
    , metadata : {}
    , tags : {}
    }
  , uiRuntime.value + "/contracts"
  , "application/vendor.iog.marlowe-runtime.contract-tx-json"
  , function(res) {
      uiBorrower.disabled = true
      uiPrincipal.disabled = true
      uiInterest.disabled = true
      uiLoanDeadline.disabled = true
      uiPaybackDeadline.disabled = true
      setContract(res.resource.contractId)
      contractUrl = uiRuntime.value + "/" + res.links.contract
      const followup = function() {
        setTx(uiCreateTx, contractId.replace(/#.*$/, ""))
        uiCreate.disabled = true
        uiLoan.disabled = false
      }
      submitTransaction(res.resource.tx.cborHex, contractUrl, waitForConfirmation(contractUrl, followup))
    }
  )
}


/**
 * Apply inputs to the contract.
 */
async function applyInputs(operation, inputs, followup) {
  buildTransaction(
    operation
  , {
      version : "v1"
    , inputs: inputs
    , metadata : {}
    , tags : {}
    }
  , contractUrl + "/transactions"
  , "application/vendor.iog.marlowe-runtime.apply-inputs-tx-json"
  , function(res) {
      transactionUrl = uiRuntime.value + "/" + res.links.transaction
      const tx = res.resource.transactionId
      submitTransaction(res.resource.tx.cborHex, transactionUrl, waitForConfirmation(transactionUrl, followup(tx)))
    }
  )
}


/**
 * Deposit loan into the contract.
 */
export async function depositLoan() {
  applyInputs(
    "deposit-loan"
  , [
      {
        input_from_party : {role_token : "Lender"}
      , that_deposits : parseInt(uiPrincipal.value)
      , of_token : {currency_symbol : "", token_name : ""}
      , into_account: {role_token : "Lender"}
      }
    ]
  , function(tx) {
      return function() {
        setTx(uiLoanTx, tx)
        uiLoan.disabled = true
        uiWithdrawLoan.disabled = false
      }
    }
  )
}


/**
 * Deposit repayment into the contract.
 */
export async function depositPayback() {
  applyInputs(
    "deposit-payback"
  , [
      {
        input_from_party : {role_token : "Borrower"}
      , that_deposits : parseInt(uiPrincipal.value) + parseInt(uiInterest.value)
      , of_token : {currency_symbol : "", token_name : ""}
      , into_account: {role_token : "Borrower"}
      }
    ]
  , function(tx) {
      return function() {
        setTx(uiPaybackTx, tx)
        uiPayback.disabled = true
        uiWithdrawPayback.disabled = false
      }
    }
  )
}


/**
 * Withdraw from the role-payout address.
 */
async function withdraw(operation, role, followup) {
  buildTransaction(
    operation
  , {
      contractId : contractId
    , role : role
    }
  , uiRuntime.value + "/withdrawals"
  , "application/vendor.iog.marlowe-runtime.withdraw-tx-json"
  , function(res) {
      transactionUrl = uiRuntime.value + "/" + res.links.withdrawal
      const tx = res.resource.withdrawalId
      submitTransaction(res.resource.tx.cborHex, transactionUrl, waitForConfirmation(transactionUrl, followup(tx)))
    }
  )
}


/**
 * Withdraw the loan from the role-payout address.
 */
export async function withdrawLoan() {
  withdraw(
    "withdraw-loan"
  , "Borrower"
  , function(tx) {
      return function() {
        setTx(uiWithdrawLoanTx, tx)
        uiWithdrawLoan.disabled = true
        uiPayback.disabled = false
      }
    }
  )
}


/**
 * Withdraw the repayment from the role-payout address.
 */
export async function withdrawPayback() {
  withdraw(
    "withdraw-payback"
  , "Lender"
  , function(tx) {
      return function() {
        setTx(uiWithdrawPaybackTx, tx)
        uiWithdrawPayback.disabled = true
        uiCreate.disabled = false
      }
    }
  )
}


/**
 * Submit a transaction.
 * @param [String]   cborHex The hexadecimal-encoded CBOR for the transaction.
 * @param [String]   url     The URL for the Marlowe Runtime endpoint for submitting the transaction.
 * @param [Function] wait    Action to be performed for waiting for the confirmation.
 */
function submitTransaction(cborHex, url, wait) {
  status("Signing transaction.")
  wallet.signTx(cborHex, true).then(function(witness) {
    const xhttp = new XMLHttpRequest()
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4) {
        console.log({operation : "submit", status : this.status, response : this.responseText})
        if (this.status == 202) {
          setTimeout(wait, delay)
	} else {
          report("Transaction submission failed.")
        }
      }
    }
    xhttp.open("PUT", url)
    xhttp.setRequestHeader("Content-Type", "application/json")
    const req = {
      type : "ShelleyTxWitness BabbageEra"
    , description : ""
    , cborHex : witness
    }
    console.log({operation : "submit", request : req})
    status("Submitting transaction.")
    xhttp.send(JSON.stringify(req))
  }).catch(function(error) {
    report(error)
  })
}


/**
 * Wait for a transaction to be confirmed.
 */
function waitForConfirmation(url, followup) {
  return function() {
    const xhttp = new XMLHttpRequest()
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4) {
        console.log({operation : "wait", status : this.status, response : this.responseText})
        if (this.status == 200) {
          const res = JSON.parse(this.responseText)
          if (res.status == "confirmed" || res.resource && res.resource.status == "confirmed") {
            setTimeout(followup, delay)
            report("Transaction confirmed.")
  	} else if (res.status == "submitted" || res.resource && res.resource.status == "submitted") {
            setTimeout(waitForConfirmation(url, followup), delay)
  	} else {
            report("Confirmation failed.")
          }
        }
      }
    }
    xhttp.open("GET", url)
    console.log({operation : "wait"})
    status("Waiting for confirmation.")
    xhttp.send()
  }
}


/**
 * Initialize the application.
 */
export async function initialize() {

  uiRuntime.value = "http://127.0.0.1:3780"
  uiRuntime.value = "http://192.168.0.12:13780"

  uiLender.disabled = true
  uiBorrower.disabled = true

  uiPrincipal.disabled = false
  uiInterest.disabled = false
  uiLoanDeadline.disabled = false
  uiPaybackDeadline.disabled = false

  uiLoan.disabled = true
  uiWithdrawLoan.disabled = true
  uiPayback.disabled = true
  uiWithdrawPayback.disabled = true

  uiPrincipal.value = 100 * ada
  uiInterest.value = 5 * ada

  const depositTime = new Date()
  depositTime.setMinutes(depositTime.getMinutes() + 10)
  uiLoanDeadline.value = depositTime.toISOString()

  const paybackDeadline = new Date()
  paybackDeadline.setMinutes(paybackDeadline.getMinutes() + 20)
  uiPaybackDeadline.value = paybackDeadline.toISOString()

  // Connect to the Eternl wallet. (Also works for Nami by changing "eternl" to "nami" in the next line.)
  cardano.eternl.enable().then(function(n) {
    wallet = n
    wallet.getChangeAddress().then(function(a) {
      setAddress(a)
      uiBorrower.value = address
      makeContract()
    }).catch(function(error) {
      report(error)
    })
  }).catch(function(error) {
    report(error)
  })

}


/**
 * Restart the application.
 */
export async function restart() {
  document.body.style.cursor = "default"
  uiCreate.disabled = false
  uiContractId.innerText = ""
  uiCreateTx.innerText = ""
  uiLoanTx.innerText = ""
  uiWithdrawLoanTx.innerText = ""
  uiPaybackTx.innerText = ""
  uiWithdrawPaybackTx.innerText = ""
  uiMessage.innerText = ""
  initialize()
}
