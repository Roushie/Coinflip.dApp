import "./Ownable.sol";
import "./provableAPI.sol";
pragma solidity 0.6.12;

contract Coinflip is Ownable, usingProvable {

  struct Bet { // We use this struct to map query IDs to bet data.
    address payable bettor_address;
    uint256 betamount;
    uint256 flipresult;
  }

  mapping (bytes32 => Bet) queries; //Create the mapping where we are gonna store every queryID and the result corresponding to that ID. When we get the ID we need to push it to the mapping.

  event QueryInitiated (
    bytes32 InitialQueryID
  );

  event QueryCompleted (
    bytes32 returnedQueryID,
    uint256 betResult,
    uint256 netamount,
    bytes proof
  );

  function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) internal {
    //require(msg.sender == provable_cbAddress()); - enable this later when converting to actual orcale
    uint256 randomnumber = uint256(keccak256(abi.encodePacked(_result))) % 2; // Takes the result, encodes it, hashes it, converts it to an integer and returns either 0 or 1 if its even / odd respectively.
    queries[_queryId].flipresult = randomnumber; //Now we have the result of the flip - let's say 1 == win
    if (queries[_queryId].flipresult == 1){
      queries[_queryId].bettor_address.transfer(queries[_queryId].betamount * 2);
    }
    emit QueryCompleted(_queryId, queries[_queryId].betamount, queries[_queryId].flipresult, _proof);
  }

  function testRandom() internal returns (bytes32) { //Testing function by Philip so that we can test on localhost. provable_newRandomDSQuery takes 3 parameters, this takes 0.
    bytes32 queryId = bytes32(keccak256(abi.encodePacked(msg.sender)));
    __callback(queryId, "1", bytes("test")); // This will eventually be called by the oracle when we get an answer. Here it is called immediately for testing purposes.
    return queryId;
  }

  function Flip() public payable { //This is what the user of the dApp calls when they make a bet. 
    bytes32 queryID = testRandom(); //We get a query ID that is saved into this variable.
    queries[queryID].bettor_address = msg.sender; //Map bettor address to random number query ID.
    queries[queryID].betamount = msg.value; //Map bet amount to random number query ID.
    emit QueryInitiated(queryID); // Emits query ID to track in JS
  }

  function withdraw(uint amount) public onlyOwner{ //Withdraws specified amount in wei
    msg.sender.transfer(amount);
  }
}
