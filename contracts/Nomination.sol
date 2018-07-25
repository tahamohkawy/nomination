pragma solidity ^0.4.11;

contract Nomination {

    bytes32 _orgaization;
    address _moderator;

    
    uint nominationStartTime = now;
    uint nominationEndTime = now+5 days;
    uint votingEndTime = nominationEndTime+10 days;
    
    struct Nominee {
        address nomineeAddress;
        bytes32 department;
    }

    Nominee[] nominees;

    mapping(address => uint) votes;
    mapping(address => bool) voted;
    
    event AnnounceWinner(address winner,uint noOfvotes,bytes32 winnerDepartment);

    /* Constructor */
    function Nomination (bytes32 organization) public {
        _moderator = msg.sender;
        _orgaization = organization;
    }

    /* Fallback function */
    function () public payable {
        //if a caller sent ether to the contract, just send it back, so caller does not lose it
        revert();
    }
    

    modifier nominatingStarted(){
        require(now >= nominationStartTime);
        _;
    }

    modifier nominatingFinished(){
        require(now >= nominationEndTime);
        _;
    }

    modifier didNotVote(){
        require(voted[msg.sender] == false);
        _;
    }
    
    modifier votingFinished(){
        require(now >= votingEndTime);
        _;
    }

    function nominate (address nominee, bytes32 department) nominatingStarted public {
        Nominee memory nom = Nominee(nominee,department);        
        nominees.push(nom);

        votes[nominee] = 0;
    }

    function vote (address nominee) nominatingFinished didNotVote public {
        votes[nominee] += 1;
        voted[msg.sender] = true;
    }

    function getNoOfVotes(address nominee) public view returns (uint) {
        return votes[nominee];
    }

    function getWinner() votingFinished public returns (address winner,uint highestNoOfVotes,bytes32 winningDepartment){
                
        for(uint i = 0;i < nominees.length;i++){
            winner = nominees[i].nomineeAddress;
            winningDepartment = nominees[i].department;

            if(votes[winner] > highestNoOfVotes){
                highestNoOfVotes = votes[winner];               
            }
        }
        emit AnnounceWinner(winner,highestNoOfVotes,winningDepartment);
    }    
}

