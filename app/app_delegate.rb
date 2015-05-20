class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    rootViewController = CropController.alloc.init

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = UINavigationController.alloc.initWithRootViewController(rootViewController)
    @window.makeKeyAndVisible

    true
  end
end

class CropController < UIViewController

  def viewDidLoad
    super
    @path = CGPathCreateMutable()
    launchEditor
    self
  end

  def launchEditor
    fillBtn = UIBarButtonItem.alloc.initWithTitle("fill", style:UIBarButtonItemStylePlain, target: self, action: "fill")
    self.navigationItem.rightBarButtonItem = fillBtn

    @mainImageView = UIImageView.alloc.initWithFrame(self.view.frame).tap do |imgv|
      imgv.contentMode = UIViewContentModeScaleAspectFit
      imgv.image = "face.png".uiimage
    end

    self.view.addSubview(@mainImageView)

    @editing = true
  end

  def touchesBegan(touches, withEvent: event)
    return if !@editing
    touch = touches.first
    touchPoint =  touch.locationInView(self.view)
    touchPoint.y -= 60
    @lastPoint = touchPoint

    @cursor = UIView.alloc.init.tap do |c|
      c.frame = [[0,0], [20,20]]
      c.center = touchPoint
      c.backgroundColor = UIColor.greenColor
      c.layer.cornerRadius = 10
    end

    self.view.addSubview(@cursor)

  end

  def touchesMoved(touches, withEvent: event)
    return if !@editing

    touch = touches.first
    currentPoint = touch.locationInView(self.view)
    currentPoint.y -= 60
    @cursor.move_to([currentPoint.x - 10, currentPoint.y - 10], duration: 0)

    drawLineFrom(@lastPoint, currentPoint)
    @lastPoint = currentPoint


  end

  def touchesEnded(touches, withEvent: event)
    @cursor.removeFromSuperview
    @cursor = nil

  end

  def drawLineFrom(fromPoint, toPoint)
    UIGraphicsBeginImageContext(self.view.frame.size)
    context = UIGraphicsGetCurrentContext()
    @mainImageView.image.drawInRect(imageViewImageBounds)

    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y)

    CGContextSetLineCap(context, KCGLineCapRound)
    CGContextSetLineWidth(context, 20.0)
    CGContextSetBlendMode(context, KCGBlendModeClear)

    path = CGContextCopyPath(context)
    CGPathAddPath(@path, nil, path)


    CGContextStrokePath(context)

    @mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

  end

  def fill
    return if !@editing
    UIGraphicsBeginImageContext(self.view.frame.size)
    context = UIGraphicsGetCurrentContext()

    # set color and stroke to test that path is copied over correctly
    # CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor)
    # CGContextAddPath(context, @path)
    # CGContextStrokePath(context)



    # Works as expected
    # CGContextBeginPath(context)
    # CGContextMoveToPoint(context, 0, 0)
    # CGContextAddLineToPoint(context, 100, 100)
    # CGContextAddLineToPoint(context, 0, 100)
    # CGContextAddLineToPoint(context, 100, 0)
    # CGContextClosePath(context)


    # Clears the whole screen / i.e. doesn't clip anything?
    CGContextAddPath(context, @path)


    CGContextClip(context)

    @mainImageView.image.drawInRect([[0,0],[self.view.frame.size.width, self.view.frame.size.height]])
    
    @mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

  end

  def imageViewImageBounds
    iv = @mainImageView
    imageSize = iv.image.size
    imageScale = [CGRectGetWidth(iv.bounds)/imageSize.width.to_f, CGRectGetHeight(iv.bounds)/imageSize.height.to_f].min
    scaledImageSize = CGSizeMake((imageSize.width.to_f*imageScale), (imageSize.height.to_f*imageScale))
    imageFrame = CGRectMake((0.5 * (CGRectGetWidth(iv.bounds)-scaledImageSize.width)), (0.5 *(CGRectGetHeight(iv.bounds)-scaledImageSize.height)), scaledImageSize.width, scaledImageSize.height)

  end

end