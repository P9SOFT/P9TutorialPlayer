//
//  TutorialKeys.swift
//  Sample
//
//  Created by 나태현 on 2017. 4. 19..
//  Copyright © 2017년 P9 SOFT, Inc. All rights reserved.
//

let sampleKey = "sampleKey"

let fullFrameKey = "fullFrameKey"
let godzillaFrameKey = "godzillaMaskFrameKey"
let kingghidorahFrameKey = "kingghidorahMaskFrameKey"
let playButtonFrameKey = "playButtonFrameKey"

func prepareTutorialPlayer() {
    
    let repositoryPath: String = NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true)[0] + "/tutorial"
    P9TutorialPlayer.defaultManager().standby(withRepositoryPath: repositoryPath)
}

func registerSamplePlay() {
    
    P9TutorialPlayer.defaultManager().setAction({ (paramDict:[AnyHashable : Any]?) in
        
        if paramDict == nil {
            return
        }
        
        let fullFrame = paramDict![fullFrameKey] as? CGRect ?? .zero
        let paragraphStyleCenter = NSMutableParagraphStyle()
        paragraphStyleCenter.alignment = .center
        let paragraphStyleLeft = NSMutableParagraphStyle()
        paragraphStyleLeft.alignment = .left
        let paragraphStyleRight = NSMutableParagraphStyle()
        paragraphStyleRight.alignment = .right
        let attributeWelcome = [NSParagraphStyleAttributeName:paragraphStyleCenter, NSFontAttributeName:UIFont.boldSystemFont(ofSize: 24.0), NSForegroundColorAttributeName:UIColor.white]
        let attributeLightGray = [NSParagraphStyleAttributeName:paragraphStyleCenter, NSFontAttributeName:UIFont.boldSystemFont(ofSize: 12.0), NSForegroundColorAttributeName:UIColor.lightGray]
        let attributeWhiteCenter = [NSParagraphStyleAttributeName:paragraphStyleCenter, NSFontAttributeName:UIFont.boldSystemFont(ofSize: 12.0), NSForegroundColorAttributeName:UIColor.white]
        let attributeWhiteLeft = [NSParagraphStyleAttributeName:paragraphStyleLeft, NSFontAttributeName:UIFont.boldSystemFont(ofSize: 12.0), NSForegroundColorAttributeName:UIColor.white]
        let attributeWhiteRight = [NSParagraphStyleAttributeName:paragraphStyleRight, NSFontAttributeName:UIFont.boldSystemFont(ofSize: 12.0), NSForegroundColorAttributeName:UIColor.white]
        let welcomeString = NSMutableAttributedString()
        welcomeString.append(NSAttributedString(string:"Welcome!", attributes:attributeWelcome))
        welcomeString.append(NSAttributedString(string:"\nTouch to continue.", attributes:attributeLightGray))
        var welcomeFrame: CGRect = .zero
        welcomeFrame.size.width = fullFrame.size.width - 40
        welcomeFrame.size.height = 80
        welcomeFrame.origin.x = (fullFrame.size.width/2) - (welcomeFrame.size.width/2)
        welcomeFrame.origin.y = (fullFrame.size.height/2) - (welcomeFrame.size.height/2)
        
        P9TutorialPlayer.defaultManager().addScriptForStringEntrance(withStringBoard: welcomeString, rect: welcomeFrame, actionType: .fadeIn, waitUntilUserTouch: true)
        P9TutorialPlayer.defaultManager().addScriptForClearBoard(with: .fadeOut, waitUntilUserTouch: false)
        
        let kingghidorahFrame = paramDict![kingghidorahFrameKey] as? CGRect ?? .zero
        var arrowFrame: CGRect = .zero
        arrowFrame.size.width = 40
        arrowFrame.size.height = 60
        arrowFrame.origin.x = kingghidorahFrame.origin.x + kingghidorahFrame.size.width - arrowFrame.size.width
        arrowFrame.origin.y = kingghidorahFrame.origin.y - arrowFrame.size.height
        var stringFrame: CGRect = .zero
        stringFrame.size.width = kingghidorahFrame.size.width
        stringFrame.size.height = 20
        stringFrame.origin.x = arrowFrame.origin.x - 5.0 - stringFrame.size.width
        stringFrame.origin.y = arrowFrame.origin.y - 5.0
        let kingghidoraString = NSMutableAttributedString()
        kingghidoraString.append(NSAttributedString(string:"This is Kingghidora,", attributes:attributeWhiteRight))
        let arrowImage = UIImage(named: "arrow")
        
        P9TutorialPlayer.defaultManager().addScriptForStringEntrance(withStringBoard: kingghidoraString, rect: stringFrame, actionType: .fromLeft, waitUntilUserTouch: false)
        P9TutorialPlayer.defaultManager().addScriptForImageEntrance(withImageBoard: arrowImage, rect: arrowFrame, actionType: .fromTop, waitUntilUserTouch: false)
        P9TutorialPlayer.defaultManager().addScriptForMaskRectangleEntrance(with: kingghidorahFrame, waitUntilUserTouch: true)
        
        let godzillaFrame = paramDict![godzillaFrameKey] as? CGRect ?? .zero
        arrowFrame.size.width = 40
        arrowFrame.size.height = 60
        arrowFrame.origin.x = godzillaFrame.origin.x + (godzillaFrame.size.width/2) - (arrowFrame.size.width/2)
        arrowFrame.origin.y = godzillaFrame.origin.y + godzillaFrame.size.height
        stringFrame.size.width = kingghidorahFrame.size.width
        stringFrame.size.height = 20
        stringFrame.origin.x = godzillaFrame.origin.x + (godzillaFrame.size.width/2) - (stringFrame.size.width/2)
        stringFrame.origin.y = arrowFrame.origin.y + arrowFrame.size.height
        let godzillaString = NSMutableAttributedString()
        godzillaString.append(NSAttributedString(string:"and Godzilla", attributes:attributeWhiteCenter))
        let upArrowImage = UIImage(cgImage: arrowImage!.cgImage!, scale: arrowImage!.scale, orientation: .downMirrored)
        
        P9TutorialPlayer.defaultManager().addScriptForClearBoard(with: .fadeOut, waitUntilUserTouch: false)
        P9TutorialPlayer.defaultManager().addScriptForMaskRectangleMove(with: godzillaFrame, waitUntilUserTouch: false)
        P9TutorialPlayer.defaultManager().addScriptForStringEntrance(withStringBoard: godzillaString, rect: stringFrame, actionType: .fromRight, waitUntilUserTouch: false)
        P9TutorialPlayer.defaultManager().addScriptForImageEntrance(withImageBoard: upArrowImage, rect: arrowFrame, actionType: .fromBottom, waitUntilUserTouch: true)
        P9TutorialPlayer.defaultManager().addScriptForClearBoard(with: .fadeOut, waitUntilUserTouch: false)
        P9TutorialPlayer.defaultManager().addScriptForMaskRectangleExit(with: godzillaFrame, waitUntilUserTouch: false)
        
        let playButtonFrame = paramDict![playButtonFrameKey] as? CGRect ?? .zero
        let handImage = UIImage(named: "hand")
        let radius = playButtonFrame.size.width/2
        var position: CGPoint = .zero
        position.x = playButtonFrame.midX
        position.y = playButtonFrame.midY
        var handFrame: CGRect = .zero
        handFrame.size.width = 40
        handFrame.size.height = 40
        handFrame.origin.x = playButtonFrame.origin.x + (playButtonFrame.size.width/2) - (handFrame.size.width/2)
        handFrame.origin.y = playButtonFrame.origin.y + playButtonFrame.size.height - (handFrame.size.height/2)
        stringFrame.size.width = fullFrame.size.width - 40
        stringFrame.size.height = 40
        stringFrame.origin.x = 20
        stringFrame.origin.y = handFrame.origin.y + handFrame.size.height + 5.0
        let resetString = NSMutableAttributedString()
        resetString.append(NSAttributedString(string:"Tutorial just play once,\nyou can't watch again it before use this reset button.", attributes:attributeWhiteLeft))
        
        P9TutorialPlayer.defaultManager().addScriptForMaskCircleEntrance(withRadius: radius, position: position, waitUntilUserTouch: false)
        P9TutorialPlayer.defaultManager().addScriptForImageEntrance(withImageBoard: handImage, rect: handFrame, actionType: .sizeUp, waitUntilUserTouch: false)
        P9TutorialPlayer.defaultManager().addScriptForStringEntrance(withStringBoard: resetString, rect: stringFrame, actionType: .sizeUp, waitUntilUserTouch: true)
        P9TutorialPlayer.defaultManager().addScriptForMaskCircleExit(withRadius: radius, position: position, waitUntilUserTouch: false)
        P9TutorialPlayer.defaultManager().addScriptForClearBoard(with: .fadeOut, waitUntilUserTouch: false)
        
    }, forKey: sampleKey)
}
