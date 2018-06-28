import Foundation
import UIKit
import Anchorage

public protocol PickerViewDelegate: class {
    func pickerView(_ pickerView: PickerView, selected index: Int)
}

public protocol PickerViewDataSource: class {
    func pickerViewNumberOfItems(_ pickerView: PickerView) -> Int
    func pickerView(_ pickerView: PickerView, itemAtIndex index: Int) -> String
}

public final class PickerView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public weak var delegate: PickerViewDelegate? {
        didSet {
            collectionView.reloadData()
        }
    }
    public weak var dataSource: PickerViewDataSource?
    private var selectedIndex: Int?
    private let layout = UICollectionViewFlowLayout()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let markerView = UIView()
    let cellWidth: CGFloat = 120
    let cellSpacing: CGFloat = 20
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        add(subview: collectionView, configure: { collectionView, pickerView in
            layout.scrollDirection = .horizontal
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            collectionView.dataSource = self
            collectionView.collectionViewLayout = layout
            collectionView.register(PickerViewCell.self, forCellWithReuseIdentifier: "PickerViewCell")
            collectionView.isScrollEnabled = true
            collectionView.alwaysBounceHorizontal = true
            collectionView.alwaysBounceVertical = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.edgeAnchors == pickerView.edgeAnchors
            collectionView.backgroundColor = UIColor.yellow
            collectionView.delegate = self
        })
        
        add(subview: markerView) { markerView, pickerView in
            markerView.widthAnchor == 2
            markerView.centerXAnchor == pickerView.centerXAnchor
            markerView.backgroundColor = .red
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let alignMiddleCell = frame.midX - (cellWidth / 2)
        layout.sectionInset = UIEdgeInsets(top: 0, left: alignMiddleCell, bottom: 0, right: alignMiddleCell)
        if let selectedIndex = selectedIndex {
            select(index: selectedIndex, animated: false)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.pickerViewNumberOfItems(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickerViewCell", for: indexPath) as! PickerViewCell
        cell.label.text = dataSource?.pickerView(self, itemAtIndex: indexPath.row)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: 40)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var closestCell : UICollectionViewCell = collectionView.visibleCells[0];
        for cell in collectionView.visibleCells {
            let closestCellDelta = abs(closestCell.center.x - collectionView.frame.midX - collectionView.contentOffset.x)
            let cellDelta = abs(cell.center.x - collectionView.frame.midX - collectionView.contentOffset.x)
            if (cellDelta < closestCellDelta){
                closestCell = cell
            }
        }
        guard let indexPath = collectionView.indexPath(for: closestCell) else {
            return
        }
        
        guard let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else {
            return
        }
        
        if let index = selectedIndex {
            if indexPath.row == index {
                print(velocity.x)
                if velocity.x >= 0, let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: index + 1, section: 0)) {
                    targetContentOffset.pointee.x = attributes.frame.origin.x - layout.sectionInset.left
                    return
                } else {
                    if let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: index - 1, section: 0)) {
                        targetContentOffset.pointee.x = attributes.frame.origin.x - layout.sectionInset.left
                        return
                    }
                }
            }
        }

        targetContentOffset.pointee.x = attributes.frame.origin.x - layout.sectionInset.left
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let index = calculateCurrentIndex() else {
            return
        }
        selectedIndex = index
        self.delegate?.pickerView(self, selected: index)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        guard let index = calculateCurrentIndex() else {
            return
        }
        selectedIndex = index
        self.delegate?.pickerView(self, selected: index)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    private func calculateCurrentIndex() -> Int? {
        var point = collectionView.contentOffset
        point.x = point.x + layout.sectionInset.left
        guard let indexPath = collectionView.indexPathForItem(at: point) else {
            return nil
        }
        return indexPath.row
    }
    
    public func select(index: Int, animated: Bool) {
        selectedIndex = index
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }
}


class PickerViewCell: UICollectionViewCell {
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView.add(subview: label, configure: { label, cell in
            cell.backgroundColor = UIColor.clear
            label.edgeAnchors == cell.edgeAnchors
            label.textColor = UIColor.black
            label.textAlignment = .center
        })
    }
}

protocol SubviewAddable {}
extension UIView: SubviewAddable {}

extension SubviewAddable where Self: UIView {
    @discardableResult
    func add<Subview: UIView>(subview: Subview, configure: (Subview, Self) -> Void) -> Subview {
        addSubview(subview)
        configure(subview, self)
        return subview
    }
}
