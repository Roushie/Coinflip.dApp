import "./Ownable.sol";
import "./provableAPI.sol";
pragma solidity 0.6.12;

contract Coinflip is Ownable, usingProvable {

constructor () public payable {
  provable_setProof(proofType_Ledger);
} // Payable because we want to deploy with ether.

  uint256 public availableBalance = address(this).balance; // This should keep track of the available balance of the contract; used to determine bet validity.

  struct Bet { // We use this struct to map query IDs to bet data.
    address payable bettor_address;
    uint256 betamount;
    uint256 flipresult;
  }

  mapping (bytes32 => Bet) queries; //Create the mapping where we are gonna store every queryID and the player address, bet amount and result corresponding to that ID.

  event QueryInitiated ( // Emit event with query ID for JS to listen for.
    bytes32 InitialQueryID
  );

  event QueryCompleted (
    bytes32 returnedQueryID,
    uint256 betResult,
    uint256 netamount,
    bytes proof
  );

  function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public {
    require(msg.sender == provable_cbAddress());
    require(provable_randomDS_proofVerify__returnCode(_queryId,_result,_proof) == 0); // Require that the proof check passes.
    uint256 randomnumber = uint256(keccak256(abi.encodePacked(_result))) % 2; // Takes the result, encodes it, hashes it, converts it to an integer and returns either 0 or 1 if its even / odd respectively.
    queries[_queryId].flipresult = randomnumber; //Now we have the result of the flip - let's say 1 == win. We store it in the mapping.
    if (queries[_queryId].flipresult == 1){ // Pay out double 50% of the time.
      queries[_queryId].bettor_address.transfer(queries[_queryId].betamount * 2);
    }
    else {
      availableBalance += queries[_queryId].betamount;
    }
    emit QueryCompleted(_queryId, queries[_queryId].flipresult, queries[_queryId].betamount, _proof); // Here we emit the data we got from the oracle.
  }

  function Flip() public payable { //This is what the user of the dApp calls when they make a bet.
    if (availableBalance < (msg.value * 2)){ //Contract balance needs to be twice the size of the bet to pay out a win, so it won't accept bets if it has less than that.
    revert();
    }
    availableBalance -= msg.value; // Subtracts bet value from available balance.
    bytes32 queryId = provable_newRandomDSQuery(0, 5, 200000); // Takes delay before execution, number of bytes requested and gas provided for callback as arguments.
    emit QueryInitiated(queryId); // Emits query ID to track in JS
    queries[queryId].bettor_address = msg.sender; //Map bettor address to random number query ID.
    queries[queryId].betamount = msg.value; //Map bet amount to random number query ID.
  }

  function withdraw(uint amount) public onlyOwner{ //Withdraws specified amount in wei
    msg.sender.transfer(amount);
  }
}
