// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { NounsToken } from 'lil-nouns/NounsToken.sol';
import './PropLotInterfaces.sol';

interface NounDaoLike {
  function propose(
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory calldatas,
    string memory description
  ) external returns (uint256);
}

contract PropLot is PropLotStorageV1 {
  /// @notice The total number of ideas
  uint256 public ideaCount;

  /// @notice The official record of all ideas ever proposed
    mapping(uint256 => Idea) internal _ideas;

  NounDaoLike dao;
  NounsToken nouns;

  /// @notice An event emitted when a new idea is created
  event IdeaCreated(
      uint256 id,
      address proposer,
      address[] targets,
      uint256[] values,
      string[] signatures,
      bytes[] calldatas,
      string description
  );

  constructor(address _nounishGovernanceContractAddress, address _nounishTokenContractAddress) {
    dao = NounDaoLike(_nounishGovernanceContractAddress);
    nouns = NounsToken(_nounishTokenContractAddress);
  }


  function suggest(
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory calldatas,
    string memory description
  ) public returns (uint256) {

    ideaCount++;
    Idea storage newIdea = _ideas[ideaCount];
    newIdea.id = ideaCount;
    newIdea.proposer = msg.sender;
    newIdea.targets = targets;
    newIdea.values = values;
    newIdea.signatures = signatures;
    newIdea.calldatas = calldatas;
    newIdea.descriptionHash = keccak256(abi.encodePacked(description));

  emit IdeaCreated(
    newIdea.id,
    msg.sender,
    targets,
    values,
    signatures,
    calldatas,
    description
  );

    return ideaCount;
  }

  /**
     * @notice function that caries out voting logic
     * @param ideaId The id of the idea to vote on
     * @param support The support value for the vote. 0=against, 1=for. No abstain (just don't vote)
     * @return The number of votes cast
     */
    function castVote(
        uint256 ideaId,
        uint8 support
    ) external returns (uint96) {
        require(support <= 1, 'PropLot::castVote: invalid vote type');
        Idea storage idea = _ideas[ideaId];
        Receipt storage receipt = idea.receipts[msg.sender];
        require(receipt.hasVoted == false, 'PropLot::castVote: voter already voted');

        /// @notice: Unlike Nouns, it's not important if vote are calculated from the time of the idea
        /// second param is block number, so we are using the previous block
        uint96 votes = nouns.getPriorVotes(msg.sender, block.number - 1);

        if (support == 0) {
            idea.againstVotes = idea.againstVotes + votes;
        } else if (support == 1) {
            idea.forVotes = idea.forVotes + votes;
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        return votes;
    }

  /// @notice The vote counts for an idea
  /// @param _ideaId The idea id
  function ideaVotes(uint256 _ideaId)
      external
      view
      returns (
          uint256,
          uint256
      )
  {
      Idea storage idea = _ideas[_ideaId];
      return (idea.againstVotes, idea.forVotes);
  }

  function graduateIdea(uint256 _ideaId, string memory description) public {
    Idea storage idea = _ideas[_ideaId];
    require(keccak256(abi.encodePacked(description)) == idea.descriptionHash,
     "Description does not match original description");

    dao.propose(idea.targets, idea.values, idea.signatures, idea.calldatas, "");
  }
}
