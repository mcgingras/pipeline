// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import 'forge-std/Test.sol';
import { DescriptorHelpers } from './DescriptorHelpers.sol';
import { NounsDescriptorV2 } from "lil-nouns/NounsDescriptorV2.sol";
import { SVGRenderer } from 'lil-nouns/SVGRenderer.sol';
import { NounsArt } from 'lil-nouns/NounsArt.sol';
import { NounsDAOExecutor } from 'lil-nouns/governance/NounsDAOExecutor.sol';
import { NounsDAOLogicV1 } from 'lil-nouns/governance/NounsDAOLogicV1.sol';
import { IProxyRegistry } from 'lil-nouns/external/opensea/IProxyRegistry.sol';
import { NounsDescriptor } from 'lil-nouns/NounsDescriptor.sol';
import { NounsSeeder } from 'lil-nouns/NounsSeeder.sol';
import { NounsToken } from 'lil-nouns/NounsToken.sol';
import { NounsDAOProxy } from 'lil-nouns/governance/NounsDAOProxy.sol';
import { Inflator } from 'lil-nouns/Inflator.sol';

abstract contract DeployUtils is Test, DescriptorHelpers {
    uint256 constant TIMELOCK_DELAY = 2 days;
    uint256 constant VOTING_PERIOD = 5_760; // About 24 hours
    uint256 constant VOTING_DELAY = 1;
    uint256 constant PROPOSAL_THRESHOLD = 1;
    uint256 constant QUORUM_VOTES_BPS = 2000;

    function _deployAndPopulateV2() internal returns (NounsDescriptorV2) {
        NounsDescriptorV2 descriptorV2 = _deployDescriptorV2();
        _populateDescriptorV2(descriptorV2);
        return descriptorV2;
    }

    function _deployDescriptorV2() internal returns (NounsDescriptorV2) {
        SVGRenderer renderer = new SVGRenderer();
        Inflator inflator = new Inflator();
        NounsDescriptorV2 descriptorV2 = new NounsDescriptorV2(NounsArt(address(0)), renderer);
        NounsArt art = new NounsArt(address(descriptorV2), inflator);
        descriptorV2.setArt(art);
        return descriptorV2;
    }

    function _deployTokenAndDAOAndPopulateDescriptor(
        address lilNoundersDAO,
        address noundersDAO,
        address vetoer,
        address minter
    ) internal returns (address, address) {
        IProxyRegistry proxyRegistry = IProxyRegistry(address(3));

        NounsDAOExecutor timelock = new NounsDAOExecutor(address(1), TIMELOCK_DELAY);
        NounsDescriptor descriptor = new NounsDescriptor();
        NounsToken nounsToken = new NounsToken(lilNoundersDAO, noundersDAO, minter, descriptor, new NounsSeeder(), proxyRegistry);
        NounsDAOProxy proxy = new NounsDAOProxy(
            address(timelock),
            address(nounsToken),
            vetoer,
            address(timelock),
            address(new NounsDAOLogicV1()),
            VOTING_PERIOD,
            VOTING_DELAY,
            PROPOSAL_THRESHOLD,
            QUORUM_VOTES_BPS
        );

        vm.prank(address(timelock));
        timelock.setPendingAdmin(address(proxy));
        vm.prank(address(proxy));
        timelock.acceptAdmin();

        nounsToken.transferOwnership(address(timelock));

        _populateDescriptor(descriptor);

        return (address(nounsToken), address(proxy));
    }
}
