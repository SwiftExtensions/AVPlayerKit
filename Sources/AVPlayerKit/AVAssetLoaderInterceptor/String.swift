//
//  String.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 02.11.2026.
//

import Foundation

extension String {
    /**
     Срезает префикс строки.
     - Parameter prefix: Префикс.
     - Returns: Кортеж: строка без префикса и признак срезания префикса
     (_`false`, если префикса не было — возвращается исходная строка_).
     */
    func dropPrefix(_ prefix: String) -> (string: String, isDropped: Bool) {
        guard self.hasPrefix(prefix) else {
            return (self, false)
        }
        return (String(self.dropFirst(prefix.count)), true)
    }


}
