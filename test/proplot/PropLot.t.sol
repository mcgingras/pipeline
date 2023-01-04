// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "forge-std/Test.sol";
import { NounsToken } from "lil-nouns/NounsToken.sol";
import { NounsDescriptorV2 } from "lil-nouns/NounsDescriptorV2.sol";
import { NounsSeeder } from "lil-nouns/NounsSeeder.sol";
import { IProxyRegistry } from "lil-nouns/external/opensea/IProxyRegistry.sol";
import { SVGRenderer } from "lil-nouns/SVGRenderer.sol";
import { NounsArt } from "lil-nouns/NounsArt.sol";
import { DeployUtils } from "./helpers/DeployUtils.sol";
import { NounsDAOLogicV1 } from 'lil-nouns/governance/NounsDAOLogicV1.sol';

import '../../src/PropLot.sol';

// yes, the beginning of this is exactly the same as the lil-nouns folder of test cases.
contract PropLotTest is Test, DeployUtils {
  NounsToken nounsToken;
  PropLot proplot;

  address lilnoundersDAO = address(1);
  address nounsDAO = address(2);
  address minter = address(3);
  address vetoer = address(4);

  function setUp() public {
    (address tokenAddress, address daoAddress) = _deployTokenAndDAOAndPopulateDescriptor(
        lilnoundersDAO,
        nounsDAO,
        vetoer,
        minter
    );

    nounsToken = NounsToken(tokenAddress);
    proplot = new PropLot(daoAddress, tokenAddress);
  }

  function testSymbol() public {
    assertEq(nounsToken.symbol(), "LILNOUN");
  }

  function testVoteOnIdea() public {
    // mint first batch of tokens
    vm.startPrank(minter);
    nounsToken.mint();
    vm.stopPrank();

    // add new idea
    address[] memory targets = new address[](1);
    targets[0] = address(nounsToken);
    uint256[] memory values = new uint256[](1);
    values[0] = 0;
    string[] memory signatures = new string[](1);
    signatures[0] = 'setDescriptor(address)';
    bytes[] memory calldatas = new bytes[](1);
    calldatas[0] = abi.encode(address(2));
    proplot.suggest(targets, values, signatures, calldatas, "Testing a new idea.");

    uint256 blockNumber = block.number + 1;
    vm.roll(blockNumber);

    vm.startPrank(lilnoundersDAO);
    proplot.castVote(0,1);
    vm.stopPrank();

    (uint256 againstVotes, uint256 forVotes)  = proplot.ideaVotes(0);
    assertEq(againstVotes, 0);
    assertEq(forVotes, 1);
  }

  function testPropLotIdeaGraduation() public {
    // mint first batch of tokens
    vm.startPrank(minter);
    nounsToken.mint();
    vm.stopPrank();

    // delegate noun to the proplot contract
    vm.startPrank(lilnoundersDAO);
    nounsToken.delegate(address(proplot));
    vm.stopPrank();

    assertEq(proplot.ideaCount(), 0);

    address[] memory targets = new address[](1);
    targets[0] = address(nounsToken);
    uint256[] memory values = new uint256[](1);
    values[0] = 0;
    string[] memory signatures = new string[](1);
    signatures[0] = 'setDescriptor(address)';
    bytes[] memory calldatas = new bytes[](1);
    calldatas[0] = abi.encode(address(2));
    proplot.suggest(targets, values, signatures, calldatas, "Test");

    assertEq(proplot.ideaCount(), 1);

    uint256 blockNumber = block.number + 1;
    vm.roll(blockNumber);

    // graduate idea
    proplot.graduateIdea(1, "Test");
  }
}
