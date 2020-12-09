let flipId;

flipContract.events.QueryInitiated(function(error, event){
  if (!error){
  flipId = event.returnValues.InitialQueryID; // Store the query ID in a variable so that we can track it.
  $("#flipresult").text("Waiting for response from oracle... ")
  }
});

flipContract.events.QueryCompleted(function(error, event){ // This is how we listen to an event in solidity. The callback only fires if the event fires.
  if (!error && flipId == event.returnValues.returnedQueryID){ //No error + returned query matches the ID of the sent query.
    $("#ethlogo").on("animationend", function(){ //Animation can't be empty for this to trigger. Just set iterations to 1.
      if (event.returnValues.betResult == 1){ //Access event return values with dot notation
        $("#flipresult").text("You won "+web3.utils.fromWei(`${event.returnValues.netamount}`, 'ether')+" ETH!")
      }
      else {
        $("#flipresult").text("You lost "+web3.utils.fromWei(`${event.returnValues.netamount}`, 'ether')+" ETH!")
      }
      $("#flipbutton").attr("disabled", false); //Reenable flip button.
      return 0;
    });
    $("#ethlogo").css({"animation-iteration-count":"1"}); // How to make an animation end after finishing current iteration.
  }
});
