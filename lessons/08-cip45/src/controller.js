/* Example of Using Marlowe Runtime with a CIP45 Wallet */


'use strict'


// Import the CIP45 support module.

import * as CardanoPeerConnect from '@fabianbormann/cardano-peer-connect'

// Use a Bech32 library for converting address formats.

import {bech32} from "bech32"


// The explorers.
let cardanoScanUrl = null
let marloweScanUrl = null

// Whether to use CIP45.
const useCIP45 = false

// Connection to the CIP30 wallet.
let wallet = null

// Address of the depositor.
let address = null

// Identifier for the contract.
let contractId = null

// URL for Marlowe Runtime's /contracts endpoint.
let contractUrl = null

// URL for Marlowe Runtime's /contract/*/transactions endpoint.
let transactionUrl = null

// The JSON for the Marlowe contract.
let contract = {}

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
  let prefix = null
  if (a[1] == "0") {
    cardanoScanUrl = "https://preprod.cardanoscan.io"
    marloweScanUrl = "https://preprod.marlowescan.com"
    prefix = "addr_test"
  } else {
    cardanoScanUrl = "https://cardanoscan.io"
    marloweScanUrl = "https://mainnet.marlowescan.com"
    prefix = "addr"
  }
  address = bech32.encode(prefix, bech32.toWords(bytes), 1000)
  const display = address.substr(0, 29) + "..." + address.substr(address.length - 24)
  uiAddress.innerHTML = "<a href='" + cardanoScanUrl + "/address/" + a + "' target='marlowe'>" + display + "</a>"
}


/**
 * Set the contract ID in the UI.
 * @param [String] c The contract ID.
 */
function setContract(c) {
  contractId = c
  uiContractId.innerHTML = "<a href='" + marloweScanUrl + "/contractView?tab=info&contractId=" + contractId.replace("#", "%23") + "' target='marlowe'>" + contractId + "</a>"
}


/**
 * Set a link to a transaction in the UI.
 * @param [Element] element The UI element for the transaction.
 * @param [String]  tx      The transaction ID.
 */
function setTx(element, tx) {
  element.innerHTML = "<a href='" + cardanoScanUrl + "/transaction/" + tx + "?tab=utxo' target='marlowe'>" + tx + "</a>"
}


/**
 * Make the JSON for the Marlowe contract.
 */
export function makeContract() {
  contract = {
    when : [
      {
        case : {
          party : {
            address : address
          }
        , deposits : parseInt(uiFundingAmount.value)
        , of_token : {
            currency_symbol : uiFundingPolicy.value
          , token_name : uiFundingName.value
          }
        , into_account : {
            role_token : uiRecipientName.innerText
          }
        }
      , then : "close"
      }
    ]
  , timeout : Date.parse(uiDepositTime.value)
  , timeout_continuation : "close"
  }
  console.log({contract : contract})
}


/**
 * Perform an operation that requires blocking the UI.
 */
function waitCursor() {
  document.body.style.cursor = "wait"
  uiCreate.style.cursor = "wait"
  uiDeposit.style.cursor = "wait"
  uiMessage.innerText = "Working . . ."
}


/**
 * Report a result and unblock the UI.
 */
function report(message) {
  status(message)
  uiCreate.style.cursor = "default"
  uiDeposit.style.cursor = "default"
  document.body.style.cursor = "default"
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
    , roles : uiRecipientPolicy.innerText
    , minUTxODeposit : 2 * ada
    , metadata : {}
    , tags : {}
    }
  , uiRuntime.innerText + "/contracts"
  , "application/vendor.iog.marlowe-runtime.contract-tx-json"
  , function(res) {
      if (res.resource.safetyErrors.length > 0) {
	report("Refusing to create contract with safety errors: " + res.resource.safetyErrors.map(x => x.detail).join(" "))
      } else {
        setContract(res.resource.contractId)
        contractUrl = uiRuntime.innerText + "/" + res.links.contract
        const followup = function() {
          uiFundingPolicy.disabled = true
          uiFundingName.disabled = true
          uiFundingAmount.disabled = true
          uiDepositTime.disabled = true
          uiCreate.disabled = true
          uiDeposit.disabled = false
          setTx(uiCreateTx, contractId.replace(/#.*$/, ""))
        }
        submitTransaction(res.resource.tx.cborHex, contractUrl, waitForConfirmation(contractUrl, followup))
      }
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
      transactionUrl = uiRuntime.innerText + "/" + res.links.transaction
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
      , that_deposits : parseInt(uiFundingAmount.value)
      , of_token : {currency_symbol : uiFundingPolicy.value, token_name : uiFundingName.value}
      , into_account: {role_token : uiRecipientName.innerText}
      }
    ]
  , function(tx) {
      return function() {
        uiFundingPolicy.disabled = false
        uiFundingName.disabled = false
        uiFundingAmount.disabled = false
        uiDepositTime.disabled = false
        uiCreate.disabled = false
        uiDeposit.disabled = true
        setTx(uiDepositTx, tx)
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
  const stateCreate = uiCreate.disabled
  const stateDeposit = uiDeposit.disabled
  uiCreate.disabled = true
  uiDeposit.disabled = true
  status("Signing transaction.")
  wallet.signTx(cborHex, true).then(function(witness) {
    const xhttp = new XMLHttpRequest()
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4) {
        console.log({operation : "submit", status : this.status, response : this.responseText})
        if (this.status == 202) {
          setTimeout(wait, delay)
	} else {
          uiCreate.disabled = stateCreate
          uiDeposit.disabled = stateDeposit
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
    uiCreate.disabled = stateCreate
    uiDeposit.disabled = stateDeposit
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
            setTimeout(function() {
              followup()
              report("Transaction confirmed.")
            }, delay)
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

  if (window.location.search) {
    const params = new URLSearchParams(window.location.search)
    uiRuntime.innerText = params.get("runtimeUrl")
    uiRecipientPolicy.innerText = params.get("recipientPolicy")
    uiRecipientName.innerText = params.get("recipientName")
  }
  if (uiRuntime.innerText == "")
    uiRuntime.innerText = "http://127.0.0.1:3780"
  if (uiRecipientPolicy.innerText == "")
    uiRecipientPolicy.innerText = "d441227553a0f1a965fee7d60a0f724b368dd1bddbc208730fccebcf" // Anyone can mint.
  if (uiRecipientName.innerText == "")
    uiRecipientName.innerText = "Token"
  uiDepositTime.value = (new Date(new Date() - ((new Date()).getTimezoneOffset() - 24 * 60) * 60 * 1000)).toISOString().replace("Z", "")

  uiFundingPolicy.disabled = false
  uiFundingName.disabled = false
  uiFundingAmount.disabled = false
  uiDepositTime.disabled = false

  uiCreate.disabled = true
  uiDeposit.disabled = true

  if (useCIP45) {
    const dAppConnect = new CardanoPeerConnect.DAppPeerConnect({
      dAppInfo: {
        name: "Marlowe CIP45 Example",
        url: "https://examples.marlowe.app:8080/cip45.html"
      },
      onApiInject: function(name, addr) {
        status("CardanoConnect API injected for wallet \"" + name + "\".")
        cardano[name].enable().then(function(n) {
          wallet = n
          wallet.getChangeAddress().then(function(a) {
            setAddress(a)
            makeContract()
            uiCreate.disabled = false
          }).catch(function(error) {
            uiCreate.disabled = true
            report(error)
          })
    }).catch(function(error) {
      report(error)
    })
      },
      onApiEject: function(name, addr) {
        status("CardanoConnect API ejected for wallet \"" + name + "\".")
      },
      verifyConnection: function(walletInfo, callback) {
        status("Verifying connection for wallet \"" + walletInfo.name + "\" at " + walletInfo.address + ".")
        callback(true, true)
      },
      onConnect: function(addr, walletInfo) {
        uiWallet.innerText = addr
        status("Connected to wallet at " + addr + ".")
        uiCreate.disabled = true
      },
      onDisconnect: function() {
        uiWallet.innerText = ""
        status("Disconnected from wallet.")
        uiCreate.disabled = true
      },
    })
    uiMeerkat.innerText = dAppConnect.getAddress()
  } else {
    uiInstructionsCIP45.style.display = "none"
    cardano.eternl.enable().then(function(n) {
      wallet = n
      wallet.getChangeAddress().then(function(a) {
        setAddress(a)
        makeContract()
        uiCreate.disabled = false
      }).catch(function(error) {
        report(error)
      })
    }).catch(function(error) {
      report(error)
    })
  }

}


/**
 * Restart the application.
 */
export async function restart() {
  document.body.style.cursor = "default"
  uiContractId.innerText = ""
  uiCreateTx.innerText = ""
  uiDepositTx.innerText = ""
  uiMessage.innerText = ""
  initialize()
}
