//
//  CardCollectionViewLayout.swift
//  Time
//
//  Created by Mistake on 3/26/20.
//

import UIKit

protocol CardLayoutDelegate: AnyObject {
  func heightForItemInCollectionView(_ collectionView: UICollectionView) -> CGFloat
}

class CardCollectionViewLayout: UICollectionViewLayout {
    // public props
    weak var delegate: CardLayoutDelegate?
    
    
    var layoutMargin = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            // only invalidate the layout if different
            if oldValue != self.layoutMargin {
                invalidateLayout()
            }
        }
    }
    
    // private props
   
    private let cellPadding: CGFloat = 6
    
    private let bounceFactor: CGFloat = 0.4

    private var cache: [UICollectionViewLayoutAttributes] = []

    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    var itemHeight: CGFloat {
        get {
            return delegate?.heightForItemInCollectionView(collectionView!) ?? 180
        }
    }

    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        var contentSize = CGSize(width: collectionView.bounds.width, height: layoutMargin.top + (itemHeight + 16) * CGFloat(collectionView.numberOfItems(inSection: 0)) + layoutMargin.bottom)
        
        if (contentSize.height < collectionView.bounds.height) {
            contentSize.height = collectionView.bounds.height
        }
        
        return contentSize
    }
   
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        self.collectionViewContentSize
        
        let layoutSize = CGSize(width: collectionView.bounds.width - layoutMargin.left - layoutMargin.right, height: collectionView.bounds.height - layoutMargin.top - layoutMargin.bottom)
        
        let itemReveal = itemHeight + 16
        
        var itemSize = CGSize(width: layoutSize.width, height: itemHeight)
        
        if itemSize.width == 0 { itemSize.width = layoutSize.width }
        if itemSize.height == 0 { itemSize.height = layoutSize.height }
        
        let itemHorizontalOffset = 0.5 * (layoutSize.width - itemSize.width)
        let itemOrigin = CGPoint(x: layoutMargin.left + floor(itemHorizontalOffset), y: 0)
        
        // Honor overwritten contentOffset
        //
        let contentOffset = collectionView.contentOffset
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        var previousTopOverlappingAttributes: [UICollectionViewLayoutAttributes?] = [nil, nil];
        let itemCount = collectionView.numberOfItems(inSection: 0)

        var firstCompressingItem = -1;
        var lastStackItem = 0
        
        for item in 0..<itemCount {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // By default all items are layed
            // out evenly with each revealing
            // only top part ...
            //
            attributes.frame = CGRect(x: itemOrigin.x, y: layoutMargin.top + itemReveal * CGFloat(item), width: itemSize.width, height: itemSize.height);

            // Cards overlap each other
            // via z depth AND transform
            //
            // KLUDGE: translation is along negative
            //         z axis as not to block scroll
            //         indicators
            //
            attributes.zIndex = item;
            attributes.transform3D = CATransform3DMakeTranslation(0, 0, CGFloat(item - itemCount));

            if (contentOffset.y + collectionView.contentInset.top < 0.0) {
                
                // Expand cells when reaching top
                // and user scrolls further down,
                // i.e. when bouncing
                //
                var frame = attributes.frame
                
                frame.origin.y -= bounceFactor * (contentOffset.y + collectionView.contentInset.top) * CGFloat(item)
                
                attributes.frame = frame

            } else if (attributes.frame.minY < contentOffset.y + layoutMargin.top) {
                
                lastStackItem = item
                
                // Topmost cells overlap stack, but
                // are placed directly above each
                // other such that only one cell
                // is visible
                //
                var frame = attributes.frame
                
                frame.origin.y = contentOffset.y + layoutMargin.top;
                
                attributes.frame = frame;

                // Keep queue of last two items'
                // attributes and hide any item
                // below top overlapping item to
                // improve performance
                //
                if let attribute = previousTopOverlappingAttributes[1] {
                    attribute.isHidden = true
                }
                
                previousTopOverlappingAttributes[1] = previousTopOverlappingAttributes[0]
                previousTopOverlappingAttributes[0] = attributes

            } else if (self.collectionViewContentSize.height > collectionView.bounds.height && contentOffset.y > self.collectionViewContentSize.height - collectionView.bounds.height) {

                // Compress cells when reaching bottom
                // and user scrolls further up,
                // i.e. when bouncing
                //
                if (firstCompressingItem < 0) {
                    firstCompressingItem = item
                } else {
                    var frame = attributes.frame
                    let delta = contentOffset.y + self.collectionView!.bounds.height - self.collectionViewContentSize.height
                    
                    frame.origin.y += bounceFactor * delta * CGFloat(firstCompressingItem - item)
                    frame.origin.y = max(frame.origin.y, contentOffset.y + self.layoutMargin.top)

                    attributes.frame = frame;
                }

            } else if item == lastStackItem + 2 {
                var frame = attributes.frame
                
                frame.origin.y += bounceFactor * (CGFloat(lastStackItem + 1) * (itemHeight + 16) - contentOffset.y)
                
                attributes.frame = frame
            } else {
                firstCompressingItem = -1;
            }
            
            layoutAttributes.append(attributes)
        }

        
        cache = layoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
      var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
      
      // Loop through the cache and look for items in the rect
      for attributes in cache {
        if attributes.frame.intersects(rect) {
          visibleLayoutAttributes.append(attributes)
        }
      }
      return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
      return cache[indexPath.item]
    }
    
    // Custom paging based on cell height
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        let parent = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)

        let itemSpace = itemHeight + 16
        var currentItemIdy = round(collectionView.contentOffset.y / itemSpace)

        // Skip to the next cell, if there is residual scrolling velocity left.
        // This helps to prevent glitches
        let vY = velocity.y
        if vY > 0 {
          currentItemIdy += 1
        } else if vY < 0 {
          currentItemIdy -= 1
        }

        let nearestPageOffset = currentItemIdy * itemSpace
        return CGPoint(x: parent.x,
                       y: nearestPageOffset)
    }
}
