/* Example of Using Marlowe Runtime with a CIP30 Wallet */


'use strict'


// Use a Bech32 library for converting address formats.

import {bech32} from "bech32"

export const b32 = bech32


// Connection to the CIP30 wallet.
var nami = null

// Address of the depositor.
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
  const display = address.substr(0, 20) + "..." + address.substr(address.length - 15)
  uiAddress.innerHTML = "<a href='https://preprod.cardanoscan.io/address/" + a + "' target='marlowe'>" + display + "</a>"
}


/**
 * Set the contract ID in the UI.
 * @param [String] c The contract ID.
 */
function setContract(c) {
  contractId = c
  uiContractId.innerHTML = "<a href='http://marlowe.palas87.es:8001/contractView?tab=info&contractId=" + contractId.replace("#", "%23") + "' target='marlowe'>" + contractId + "</a>"
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
  contract = {
    when : [
      {
        case : {
          party : { address : address }
        , deposits : parseInt(uiAmount.value)
        , of_token : { currency_symbol : "", token_name : "" }
        , into_account : { address : uiReceiver.value }
        }
      , then : {
          when : []
        , timeout : Date.parse(uiReleaseTime.value)
        , timeout_continuation : "close"
        }
      }
    ]
  , timeout : Date.parse(uiDepositTime.value)
  , timeout_continuation : "close"
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
  uiDeposit.style.cursor = "wait"
  uiRelease.style.cursor = "wait"
  uiMessage.innerText = "Working . . ."
}


/**
 * Report a result and unblock the UI.
 */
function report(message) {
  document.body.style.cursor = "default"
  uiCreate.style.cursor = "default"
  uiDeposit.style.cursor = "default"
  uiRelease.style.cursor = "default"
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
    , roles : null
    , minUTxODeposit : 2 * ada
    , metadata : {}
    , tags : {}
    }
  , uiRuntime.value + "/contracts"
  , "application/vendor.iog.marlowe-runtime.contract-tx-json"
  , function(res) {
      uiReceiver.disabled = true
      uiAmount.disabled = true
      uiDepositTime.disabled = true
      uiReleaseTime.disabled = true
      setContract(res.resource.contractId)
      contractUrl = uiRuntime.value + "/" + res.links.contract
      const followup = function() {
        setTx(uiCreateTx, contractId.replace(/#.*$/, ""))
        uiCreate.disabled = true
        uiDeposit.disabled = false
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
 * Deposit funds into the contract.
 */
export async function depositFunds() {
  applyInputs(
    "deposit"
  , [
      {
        input_from_party : {address : address}
      , that_deposits : parseInt(uiAmount.value)
      , of_token : {currency_symbol : "", token_name : ""}
      , into_account: {address : uiReceiver.value}
      }
    ]
  , function(tx) {
      return function() {
        setTx(uiDepositTx, tx)
        uiDeposit.disabled = true
        uiRelease.disabled = false
      }
    }
  )
}


/**
 * Release the funds from the contract.
 */
export async function releaseFunds() {
  applyInputs(
    "release"
  , []
  , function(tx) {
      return function() {
        setTx(uiReleaseTx, tx)
        uiRelease.disabled = true
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
  nami.signTx(cborHex, true).then(function(witness) {
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
          if (res.resource.status == "confirmed") {
            setTimeout(followup, delay)
            report("Transaction confirmed.")
  	} else if (res.resource.status == "submitted") {
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

  uiReceiver.disabled = false
  uiAmount.disabled = false
  uiDepositTime.disabled = false
  uiReleaseTime.disabled = false

  uiDeposit.disabled = true
  uiRelease.disabled = true

  uiAmount.value = 10 * ada

  const depositTime = new Date()
  depositTime.setMinutes(depositTime.getMinutes() + 10)
  uiDepositTime.value = depositTime.toISOString()

  const releaseTime = new Date()
  releaseTime.setMinutes(releaseTime.getMinutes() + 15)
  uiReleaseTime.value = releaseTime.toISOString()

  // Connect to the Nami wallet.
  cardano.nami.enable().then(function(n) {
    nami = n
    nami.getChangeAddress().then(function(a) {
      setAddress(a)
      uiReceiver.value = address
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
  uiDepositTx.innerText = ""
  uiReleaseTx.innerText = ""
  uiMessage.innerText = ""
  initialize()
}
