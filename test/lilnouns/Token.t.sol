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

contract TokenTest is Test, DeployUtils {
  NounsToken nounsToken;
  address lilnoundersDAO = address(1);
  address nounsDAO = address(2);
  address minter = address(3);

  function setUp() public {
    NounsDescriptorV2 descriptor = _deployAndPopulateV2();

    nounsToken = new NounsToken(
      lilnoundersDAO,
      nounsDAO,
      minter,
      descriptor,
      new NounsSeeder(),
      IProxyRegistry(address(0))
    );
  }

  function testSymbol() public {
    assertEq(nounsToken.symbol(), "LILNOUN");
  }

  function testName() public {
    assertEq(nounsToken.name(), "LilNoun");
  }

  function testMintANounToSelfAndRewardsLilNoundersDao() public {
    vm.prank(minter);
    nounsToken.mint();

    assertEq(nounsToken.ownerOf(0), lilnoundersDAO);
    assertEq(nounsToken.ownerOf(1), nounsDAO);
    assertEq(nounsToken.ownerOf(2), minter);
  }

  function testRevertsOnNotMinterMint() public {
    vm.expectRevert("Sender is not the minter");
    nounsToken.mint();
  }
}
