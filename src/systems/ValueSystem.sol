// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { ValueComponent, ID as ValueCompID } from "components/ValueComponent.sol";

uint256 constant ID = uint256(keccak256("system.value"));

contract ValueSystem is System {
	constructor(IWorld _world, address _components) System(_world, _components) {}

	function execute(bytes memory arguments) public returns (bytes memory) {
		uint256 val = abi.decode(arguments, (uint256));
		ValueComponent(getAddressById(components, ValueCompID)).set(1, val);
		return "";
	}

	function executeTyped(uint256 val) public returns (bytes memory) {
		return execute(abi.encode(val));
	}
}
