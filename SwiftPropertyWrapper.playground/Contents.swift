import UIKit

// 设计动机：将属性用 wrapper 类型包裹一层。可以将属性定义、管理属性存储的代码分开，管理的代码只要写一次，就可以用在多个属性上，让属性自己决定使用哪个 wrapper

// 使用 property wrapper 进行封装
// 确保值始终小于或等于12
@propertyWrapper
struct TwelveOrLess {
    private var number: Int
    
    // wrappedValue变量的名字是固定的
    var wrappedValue: Int {
        get { return number }
        set { number = min(newValue, 12) }
    }
    
    init() {
        self.number = 0
    }
}

struct SmallRectangle {
    @TwelveOrLess var height: Int
    @TwelveOrLess var width: Int
}

var rectangle = SmallRectangle()
print(rectangle.height) // 0

rectangle.height = 10
print(rectangle.height) // 10

rectangle.height = 24
print(rectangle.height) // 12

//struct TestRecttangle {
//    var height: Int
//    var width: Int
//}
//
//TestRecttangle()

// 被 property wrapper 声明的属性，实际上在存储时的类型是TwelveOrLess，
// 只不过编译器施了一些魔法，让它对外暴露的类型依然是被包装的原来的类型。
// 上面的 SmallRectangle 结构体，可以
/*
struct SmallRectangle {
    private var _height = TwelveOrLess()
    private var _width = TwelveOrLess()
    var height: Int {
        get { return _height.wrappedValue }
        set { _height.wrappedValue = newValue }
    }
    var width: Int {
        get { return _width.wrappedValue }
        set { _width.wrappedValue = newValue }
    }
}
 */



// propertyWrapper - 设置初始值

@propertyWrapper
struct SmallNumber {
    private var maximum: Int
    private var number: Int
    
    var wrappedValue: Int {
        get { return number }
        set { number = min(newValue, maximum) }
    }
    
    init() {
        maximum = 12
        number = 0
    }
    
    init(wrappedValue: Int) {
        print("init(wrappedValue:)")
        maximum = 12
        number = min(wrappedValue, maximum)
    }
    
    init(wrappedValue: Int, maximum: Int) {
        print("init(wrappedValue:maximum:)")
        self.maximum = maximum
        number = min(wrappedValue, maximum)
    }
}

/*
// 使用了@SmallNumber但没有指定初始化值
struct ZeroRectangle {
    @SmallNumber var height: Int
    @SmallNumber var width: Int
}

var zeroRectangle = ZeroRectangle()
print(zeroRectangle.height, zeroRectangle.width) // 0 0
*/

/*
// 使用了@SmallNumber，并指定初始化值
// 这里会调用 init(wrappedValue:) 方法
struct UnitRectangle {
    @SmallNumber var height: Int = 1
    @SmallNumber var width: Int = 1
}

var unitRectangle = UnitRectangle()
print(unitRectangle.height, unitRectangle.width) // 1 1
*/

/*
// 使用@SmallNumber，并传参进行初始化
// 这里会调用 init(wrappedValue:maximum:) 方法
struct NarrowRectangle {
    // 报错：Extra argument 'wrappedValue' in call
    // @SmallNumber(wrappedValue: 2, maximum: 5) var height: Int = 1
    // 这种初始化是可以的，调用 init(wrappedValue:maximum:) 方法
    // @SmallNumber(maximum: 9) var height: Int = 2
    @SmallNumber(wrappedValue: 2, maximum: 5) var height: Int
    @SmallNumber(wrappedValue: 3, maximum: 4) var width: Int
}

var narrowRectangle = NarrowRectangle()
print(narrowRectangle.height, narrowRectangle.width) // 2 3

narrowRectangle.height = 100
narrowRectangle.width = 100
print(narrowRectangle.height, narrowRectangle.width) // 5 4
*/


// propertyWrapper - projectedValue

@propertyWrapper
struct SmallNumber1 {
    private var number: Int
    var projectedValue: Bool
    init() {
        self.number = 0
        self.projectedValue = false
    }
    var wrappedValue: Int {
        get { return number }
        set {
            if newValue > 12 {
                number = 12
                projectedValue = true
            } else {
                number = newValue
                projectedValue = false
            }
        }
    }
}
struct SomeStructure {
    @SmallNumber1 var someNumber: Int
}
var someStructure = SomeStructure()

someStructure.someNumber = 4
print(someStructure.$someNumber) // false

someStructure.someNumber = 55
print(someStructure.$someNumber) // true

// someStructure.$someNumber 访问的是 projectedValue


/*
 property wrapper 的局限性

 不能在协议里的属性使用。
 不能再 enum 里用。
 wrapper 属性不能定义 getter or setter 方法。
 不能在 extension 里用，因为 extension 里面不能有存贮属性。
 class 里的 wrapper property 不能覆盖其他的 property。
 wrapper 属性不能是 lazy、 @NSCopying、 @NSManaged、 weak、 或者、unowned.
 */

/*
protocol SomeProtocol {
    @SmallNumber1 var sp: Bool { get set }
}

enum SomeEnum {
    @SmallNumber1 case a
    case b
}

struct SomeStructure2 {
    @SmallNumber1 var someNumber: Int {
        get {
            return 0
        }
    }
}

extension SomeStructure {
    var someProperty1: Int {
        get {
            return 0
        }
    }
    
    @SmallNumber1 var someProperty2: Int
}

class AClass {
    @SmallNumber1 var aProperty: Int
}

class BClass: AClass {
    override var aProperty: Int = 1
}
*/


// 资料
// 官方文档 https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID617
// (三) SwiftUI - property wrapper https://juejin.cn/post/6897939241478094856
// apple / swift-evolution https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md
