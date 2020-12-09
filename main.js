let web3 = new Web3(Web3.givenProvider); //givenProvider returns the browser's native provider if using an Eth-compatible browser.
let flipContract = new web3.eth.Contract(abi, "0xfBC94755eCf0D990c17ae48195686DDec65857A6"); // Deleted from: currentAccount
let currentAccount;

$(document).ready(function(){
  $("#metamask_login_button").click(metamaskLogin);
  $("#flipbutton").click(createBet);
});

async function metamaskLogin(){ //Open metamask
  const accounts = await ethereum.request({method: "eth_requestAccounts"});
  currentAccount = accounts[0];
  $("#currentaccount").text(currentAccount);
}

async function createBet(){
  if (!currentAccount){ //Require login
    $("#flipresult").text("Please log in first.")
    return 1;
  }

  if (Math.sign($("#flipamount").val()) != 1){ //Math.sign returns 1 in case of a positive int
    $("#flipresult").text("Please enter a positive integer")
    return 2;
  }

  let betamount = parseInt(web3.utils.toWei($("#flipamount").val())) //Had a bug here, because web3 functions often return strings; I thought I was comparing numbers, but I was actually comparing strings.
  let contractbalance = parseInt(await web3.eth.getBalance(flipContract.options.address))
  console.log(betamount)
  console.log(contractbalance)
  if (contractbalance < betamount){ // We don't let the user make a bet, if the contract doesn't have the balance to pay out a win.
    $("#flipresult").text("Insufficient contract balance to accept this bet. Maximum bet is: "
    + web3.utils.fromWei(`${contractbalance}`, "ether") + " ETH")
    return 3;
  }

  else {
    flipContract.methods.Flip().send({from: currentAccount, value: betamount}).on("transactionHash", function(){ //Finally, we call the flip function in the SC once all the handlers are set up.
      $("#flipbutton").attr("disabled", true);
      $("#ethlogo").css("animation", "test 3s ease infinite"); // Start the animation, set as infinite because we don't know how long the query will take.
      $("#flipresult").text("Waiting for confirmation...") //.on "transactionHash" is a proxy monitor for clicking confirm in metamask.
    })
  };
};
