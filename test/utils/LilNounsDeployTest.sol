// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "lil-nouns/NounsToken.sol";
import "lil-nouns/NounsSeeder.sol";
import "lil-nouns/NounsDescriptorV2.sol";
import "lil-nouns/SVGRenderer.sol";


// Designed to test deploying lil nouns contract suite
// This is not something prop-lot protocol is concerned with, lil nouns is already deployed.
// But to test prop lot protocol's compatibility with lil nouns, we need this deployed as a test.
contract LilNounsDeployTest is Test {

  // the nouns token
  address internal tokenImpl;
  //
  address internal descriptorImpl;
  //
  address internal seederImpl;
  //
  address internal proxyRegistryImpl;
  //
  address internal svgRendererImpl;

  function setUp() public virtual {
    // not sure if this is going to work, I think its the proxy contract deployed to mainnet?
    // we might need to deploy one locally for this to work.
    proxyRegistryImpl = address('0xa5409ec958c83c3f309868babaca7c86dcb077c1');
    // art, renderer
    descriptorImpl = address(new NounsDescriptorV2(address(0), svgRendererImpl));

    // seeder has no constructor -- how to deploy without a constructor?
    // svgRenderer has no constructor -- how to deploy without a constructor?

    // lilNounders, nouns, minter, descriptor, seeder, proxyRegistry
    tokenImpl = address(new Token(address(0), address(0), address(0), descriptorImpl, seederImpl, proxyRegistryImpl));
  }
}