// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "lil-nouns/NounsArt.sol";
import "lil-nouns/NounsToken.sol";
import "lil-nouns/NounsSeeder.sol";
import "lil-nouns/NounsDescriptorV2.sol";
import "lil-nouns/SVGRenderer.sol";
import "lil-nouns/external/opensea/IProxyRegistry.sol";
import "lil-nouns/NounsAuctionHouse.sol";


// Designed to test deploying lil nouns contract suite
// This is not something prop-lot protocol is concerned with, lil nouns is already deployed.
// But to test prop lot protocol's compatibility with lil nouns, we need this deployed as a test.
contract LilNounsDeployTest is Test {

  // the nouns token
  NounsToken internal tokenImpl;
  IProxyRegistry internal proxyRegistryImpl;
  NounsDescriptorV2 internal descriptorImpl;
  NounsArt internal nounsArt;
  SVGRenderer internal svgRendererImpl;
  NounsSeeder internal seederImpl;

  function setUp() public virtual {
    // art, renderer
    descriptorImpl = new NounsDescriptorV2(nounsArt, svgRendererImpl);

    // lilNounders, nouns, minter, descriptor, seeder, proxyRegistry
    // minter should be auctionHouseProxy
    tokenImpl = new NounsToken(address(0), address(0), address(0), descriptorImpl, seederImpl, proxyRegistryImpl);
  }

  function testTest() public {
  }
}