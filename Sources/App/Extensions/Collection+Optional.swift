//
//  Collection+Optional.swift
//  
//
//  Created by Alex Loren on 6/13/22.
//

extension Collection {
	subscript(optional i: Index) -> Iterator.Element? {
		return self.indices.contains(i) ? self[i] : nil
	}
}
