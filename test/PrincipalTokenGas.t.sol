// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console, stdStorage, StdStorage} from "forge-std/Test.sol";
import {IPrincipalToken} from "../src/IPrincipalToken.sol";
import {IERC20} from "openzeppelin-contracts/interfaces/IERC20.sol";

contract PrincipalTokenGas is Test {
    using stdStorage for StdStorage;

    IPrincipalToken public pt;

    address public ptSwInwstETHs = 0x4ae0154F83427A5864e5de6513a47dAC9E5D5a69; // PT-sw-inwstETHs-1752969615
    address public ptwstUSR = 0xD0097149AA4CC0d0e1fC99B8BD73fC17dC32C1E9; // PT-wstUSR-1740182579
    address public ptSwynETH = 0xbBA9b8E2F698d2B1d79b6ee9FB05ac2520696F6d; // PT-sw-ynETH-1743379491

    address public user = address(10);

    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    function setUp() public {
        uint256 mainnetFork = vm.createFork(MAINNET_RPC_URL, 21714750);
        vm.selectFork(mainnetFork);

        pt = IPrincipalToken(ptSwInwstETHs);

        vm.deal(user, 1 ether);

        fundUserWithPtToken(user, 10e18);
    }

    function fundUserWithPtToken(address _to, uint248 _amount) private {
        address tokenAddress = address(pt);
        stdstore
            .enable_packed_slots()
            .target(tokenAddress)
            .sig("balanceOf(address)")
            .with_key(_to)
            .checked_write(_amount);

        assertEq(IERC20(tokenAddress).balanceOf(_to), _amount);
    }

    function test_redeemIbt_gasUsage() external {
        vm.startPrank(user);
        vm.warp(pt.maturity() + 1);

        uint256 shares = 1e18;

        uint256 gasBefore = gasleft();
        pt.redeemForIBT(shares, user, user);
        console.log("1st call gas used %d", gasBefore - gasleft());

        gasBefore = gasleft();
        pt.redeemForIBT(shares, user, user);
        console.log("2nd call gas used %d", gasBefore - gasleft());

        vm.stopPrank();
    }

    function test_withdrawIbt_gasUsage() external {
        vm.startPrank(user);
        vm.warp(pt.maturity() + 1);
        uint256 ibts = 1e18;

        uint256 gasBefore = gasleft();
        pt.withdrawIBT(ibts, user, user);
        console.log("1st call gas used %d", gasBefore - gasleft());

        gasBefore = gasleft();
        pt.withdrawIBT(ibts, user, user);
        console.log("2nd call gas used %d", gasBefore - gasleft());

        vm.stopPrank();
    }
}
