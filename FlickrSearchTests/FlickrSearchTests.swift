//
//  FlickrSearchTests.swift
//  FlickrSearchTests
//
//  Created by Gaurav Singh on 21/07/18.
//  Copyright © 2018 Gaurav Singh. All rights reserved.
//

import XCTest
@testable import FlickrSearch

class FlickrServiceMock: FlickrService {
    
    private let photos: [FlickrPhotoItem]
    private var morePhotos: [FlickrPhotoItem]?
    private var error: Error?
    
    init(photos: [FlickrPhotoItem], morePhotos: [FlickrPhotoItem]? = nil, error: Error?) {
        self.photos = photos
        self.morePhotos = morePhotos
        self.error = error
    }
    
    override func searchPhotosFor(query: String, completion: @escaping ([FlickrPhotoItem]?, Error?) -> Void) {
        if let error = error {
            completion(nil, error)
        } else {
            completion(photos, nil)
        }
    }
    
    override func loadMore(completion: @escaping ([FlickrPhotoItem]?, Error?) -> Void) {
        completion(morePhotos, nil)
    }
}

class FlickrSearchViewMock: NSObject, FlickrSearchView {
    var gotFlickrURLs = false
    var gotMoreURLs = false
    var gotError = false
    
    func searchViewDidStartLoading(isNewSearch: Bool) {
        // Nothing to do here
    }
    
    func searchViewDidFinishedLoading(isNewSearch: Bool, urls: [URL]?, error: Error?) {
        if urls != nil {
            gotFlickrURLs = isNewSearch
            gotMoreURLs = !isNewSearch
        } else if error != nil {
            gotError = true
        }
    }
    
}

class FlickrSearchTests: XCTestCase {
    
    let errorMockService = FlickrServiceMock(photos: [], error: FSError.unknownResponse)
    let photosMockService = FlickrServiceMock(photos: [FlickrPhotoItem(id: "28654654777", farm: 1, server: "850", secret: "2a7099335d"), FlickrPhotoItem(id: "42824251994", farm: 2, server: "1786", secret: "3176de0883")], error: nil)
    let morePhotosMockService = FlickrServiceMock(photos: [FlickrPhotoItem(id: "28654654777", farm: 1, server: "850", secret: "2a7099335d"), FlickrPhotoItem(id: "42824251994", farm: 2, server: "1786", secret: "3176de0883")], morePhotos: [FlickrPhotoItem(id: "28673236207", farm: 2, server: "1789", secret: "34eec8ec21")], error: nil)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShoudSetFlickerURLsForPhotoItems() {
        // given
        let flickrViewMock = FlickrSearchViewMock()
        let presenterUnderTest = FlickrSearchPresenter(service: photosMockService)
        presenterUnderTest.attachView(view: flickrViewMock)
        
        // when
        presenterUnderTest.searchFlickr(forQuery: "kitten")
        
        // verify
        XCTAssertTrue(flickrViewMock.gotFlickrURLs)
    }
    
    func testLoadMorePhotos() {
        // given
        let flickrViewMock = FlickrSearchViewMock()
        let presenterUnderTest = FlickrSearchPresenter(service: morePhotosMockService)
        presenterUnderTest.attachView(view: flickrViewMock)
        
        // when
        presenterUnderTest.searchFlickr(forQuery: "kitten")
        presenterUnderTest.loadMore()
        
        // verify
        XCTAssertTrue(flickrViewMock.gotMoreURLs)
    }
    
    func testErrorForErrorInFlickrServie() {
        // given
        let flickrViewMock = FlickrSearchViewMock()
        let presenterUnderTest = FlickrSearchPresenter(service: errorMockService)
        presenterUnderTest.attachView(view: flickrViewMock)
        
        // when
        presenterUnderTest.searchFlickr(forQuery: "kitten")
        
        // verify
        XCTAssertTrue(flickrViewMock.gotError)
    }
}
