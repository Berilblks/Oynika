import UIKit
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {
  func testHomeOnLeftMeansNaturalXPointsDown() {
    XCTAssertEqual(whoLandscapeUpSign(for: .landscapeLeft), -1.0)
  }
  func testHomeOnRightMeansNaturalXPointsUp() {
    XCTAssertEqual(whoLandscapeUpSign(for: .landscapeRight), 1.0)
  }
  func testPortraitAndUnknownDoNotInventLandscapeHint() {
    XCTAssertNil(whoLandscapeUpSign(for: .portrait))
    XCTAssertNil(whoLandscapeUpSign(for: .portraitUpsideDown))
    XCTAssertNil(whoLandscapeUpSign(for: .unknown))
  }
}
