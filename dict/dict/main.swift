//
//  main.swift
//  dict
//
//  Created by Eular on 7/24/16.
//  Copyright © 2016 Eular. All rights reserved.
//

// Links
// - http://tobioka.net/716
// - http://blog.ready4go.com/blog/2013/06/18/use-dictionary-from-command-line-in-mac-os/
// - https://github.com/jakwings/macdict/blob/master/macdict2.swift
// - https://github.com/sekimura/lookup/blob/master/lookup.swift

import Foundation

extension String {
    
    func regReplace(_ pattern: String, replaced: String, option: RegularExpression.Options = .caseInsensitive) -> String {
        let regex = try! RegularExpression(pattern: pattern, options: option)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: replaced)
    }
    
}

let argv = Process.arguments
let appName = argv[0].components(separatedBy: "/").last ?? "dict"

func usage() {
    print("Version: 1.0")
    print("Author: Urinx")
    print("Github: https://github.com/Urinx/dict")
    print("Usage: ./\(appName) [word]\n")
}

func lookup(_ word: String) {
    var definition_string = "\tnot found"
    let range: CFRange = DCSGetTermRangeInString(nil, word, 0)
    
    if range.location != -1 {
        if let definition = DCSCopyTextDefinition(nil, word, range) {
            definition_string = definition.takeRetainedValue() as String
            
            definition_string = definition_string.regReplace("(▶)", replaced: "\n$0")
            definition_string = definition_string.regReplace("\\b(\\d)\\b", replaced: "\n$0")
            definition_string = definition_string.regReplace("([•●])", replaced: "\n$0")
            definition_string = definition_string.regReplace("\\b(PHRASES)\\b", replaced: "\n\n$0\n-------\n")
            definition_string = definition_string.regReplace("(ORIGIN)", replaced: "\n\n$0\n------\n", option: .dotMatchesLineSeparators)
            definition_string = definition_string.regReplace("\\|\\w+\\|\\s(noun|verb)?\\s", replaced: "$0\n")
            definition_string = definition_string.regReplace("[\\u4e00-\\u9fa5]+\\s", replaced: "$0\n")
        }
    }
    
    print("=> look up: \(word)")
    print("=> definition:\n\(definition_string)")
    
}

func main() {
    if argv.count != 2 {
        usage()
    } else {
        if let word = argv.last {
            lookup(word)
        }
    }
}


main()
