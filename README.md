# Purpose

This is a library that is intended to be used to generate ray traced scenes. I had originally implemented this in Clojure but I wanted to learn more about Swift by reimplementing it in that language. It's a library instead of an application like POV-Ray, but there is a component in it that allows you to easily create an object scene by expressing it in a Swift DSL, and then render it to a file. Moreover, since you can use Xcode to type in a scene, you can take advantage of its own features like type-checking and fixits, which were not possible using Clojure. We're effectively using Xcode as a GUI for running a set of sketches. As with the Clojure implementation, this one is based on the tests provided by the amazing book, The Ray Tracer Challenge by Jamis Buck.

# Quick start

* Open Xcode
* Create a new project, using the Command Line Tool template
* Add this library, via File -> Add Packages...
  * Enter the URL of this repo, https://github.com/quephird/ScintillaLib, in the search field
  * Click the Add Package button in the main dialog box
  * Click the Add Package button in the new confirmation dialog box
  * Observe that ScintillaLib is now in the list under Package Dependencies in the Project Navigator
* Delete main.swift
* Create a new Swift file, say QuickStart.swift and add the following code:

```swift
import ScintillaLib

@main
struct QuickStart: ScintillaApp {
    var body = World {
        PointLight(point(-10, 10, -10))
        Camera(400, 400, PI/3, .view(
            point(0, 2, -2),
            point(0, 0, 0),
            vector(0, 1, 0)))
        Sphere()
            .material(.solidColor(Color(1, 0, 0)))
    }
}
```

* Ensure that the project builds via Product -> Build
* Run the project and observe that a new file, `QuickStart.ppm`, now exists on your desktop, and that opening it up results in an image that looks like this:

![](./images/QuickStart.png)

# Features

This ray tracer allows you to describe and render scenes using a light source, a camera, and a collection of shapes, each shape having an associated material. Shapes can then be combined with each other using constructive solid geometry.

## Shapes

The following shapes are available:

| Shape | Defaults |
| --- | --- |
| Plane | Lies in the xz-plane |
| Sphere | Centered at the origin and has radius of one unit |
| Cube | Centered at the origin and has "radius" of one unit |
| Cone | Centered at the origin, has radius of one unit and infinite length along the y-axis, and has exposed caps |
| Cylinder | Centered at the origin, has radius of one unit and infinite length along the y-axis, and has exposed caps |
| Torus | Centered at the origin, lies in the xz-plane, had major radius of two and a minor radius of one |

Currently, all shapes must minimally be constructed with a `Material`, the details of which explained below.

All shapes also have the following property modifiers for setting/updating the underlying transformation matrix:

* `translate(_ x: Double, _ y: Double, _ z: Double)`
* `scale(_ x: Double, _ y: Double, _ z: Double)`
* `rotateX(_ t: Double)`
* `rotateY(_ t: Double)`
* `rotateZ(_ t: Double)`
* `shear(_ xy: Double, _ xz: Double, _ yx: Double, _ yz: Double, _ zx: Double, _ zy: Double)`

This means that you can chain operations together in a logical manner and not have to explicitly `let` out a transformation matrix and then pass it in to the shape's constructor, like this:

```swift
Cube()
    .shear(1, 1, 0, 1, 0, 0)
    .scale(1, 2, 3)
    .rotateX(PI/3)
    .rotateY(PI/3)
    .rotateZ(PI/3)
    .translate(0, 1, 2)
```

The implementation applies the underlying transformation matrices in reverse order, so the programmer isn't burdened with those details and instead can simply chain operations in an intuitive manner.

## Implicit surfaces

Implicit surfaces are actually a subclass of `Shape` but are used a little differently from the other types. Implicit surfaces are created with a material _and_ a closure that represents the function F in the equation that defines the surface in terms of the three coordinates, namely:

<p align="center">
F(x, y, z) = 0
</p>

Since it is not possible to compute the bounds of an arbitrary choice of F, Scintilla needs to somehow be informed of them. The user can specify them by passing in a pair of 3-tuples representing the bottom-left-front and top-right-rear corners of a bounding box. If they do not, Scintilla defaults to a bounding box defined by (-1, -1, -1) and (1, 1, 1). Below is example code for rendering an implicit surface with an explicit bounding box for the equation:

<p align="center">
x² + y² + z² + sin(4x) + sin(4y) + sin(4z) = 1
</p>

```
import Darwin
import ScintillaLib

@main
struct MyWorld: ScintillaApp {
    var body = World {
        PointLight(point(-10, 10, -10))
        Camera(800, 600, PI/3, .view(
            point(0, 0, -5),
            point(0, 0, 0),
            vector(0, 1, 0)))
        ImplicitSurface(((-2, -2, -2), (2, 2, 2))) { x, y, z in
            x*x + y*y + z*z + sin(4*x) + sin(4*y) + sin(4*z) - 1
        }
            .material(.solidColor(Color(0.2, 1, 0.5)))
    }
}
```

... and here is what that looks like:

![](./images/ImplicitSurface.png)

Otherwise, they can be used just like any other primitive shape; they can be translated, scaled, and rotated, and all of their material properties work the same way as well.

## Prisms

Another `Shape` type that is available in Scintilla is the `Prism` object. To use a prism you need to pass in three parameters to the constructor:

* The base y-value
* The top y-value
* An array of tuples of `Double`s representing (x, z) coordinates of the vertices of a polygon 

The shape is extruded along the y-axis starting from the base y-value to the top one. Here is an example of a star-based prism:

```
import Darwin
import ScintillaLib

@main
struct PrismScene: ScintillaApp {
    var body: World {
        PointLight(point(-5, 5, -5))
        Camera(400, 400, PI/3, .view(
            point(0, 5, -5),
            point(0, 1, 0),
            vector(0, 1, 0)))
        Prism(
            0.0, 2.0,
            [(1.0, 0.0), (1.5, 0.5), (0.5, 0.5), (0.0, 1.0), (-0.5, 0.5),
             (-1.5, 0.5), (-1.0, 0.0), (-1.0, -1.0), (0.0, -0.5), (1.0, -1.0)]
        )
            .material(.solidColor(Color(1, 0.5, 0)))
        Plane()
            .material(.solidColor(.white))
    }
}
```

![](./images/Prism.png)

For now, only line segments joining the vertices are supported; perhaps in the future Beziér curves can be. Nonetheless, both convex _and_ concave polygons are fully supported.

## Materials

Currently materials employ either a solid color or a pattern, as well as have the following other attributes:

| Property | Range of values |
| --- | --- |
| ambient reflectance | 0.0 - 1.0 |
| diffuse reflectance | 0.0 - 1.0 |
| specular reflectance | 0.0 - 1.0 |
| shininess | 0.0 - ∞ |
| reflective index | 0.0 - 1.0 |
| transparency | 0.0 - 1.0 |
| refractive index | 1.0 - 2.5|

There is a default material, `Material.basicMaterial()`, that can be used as a convenience, with default values for all of the other attributes, or you can instantiate a `Material` with either another solid color or a pattern, namely `.solidColor()` and `.pattern()`, respectively.


Like `Shape`, `Material` has property modifers which can be used to specify values for the other attributes without having to pass non-default values for them all at once:

* `.ambient(_ n: Double)`
* `.diffuse(_ n: Double)`
* `.specular(_ n: Double)`
* `.shininess(_ n: Double)`
* `.reflective(_ n: Double)`
* `.transparency(_ n: Double)`
* `.refractive(_ n: Double)`

The following patterns are available:

* Stripes
`Pattern(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4)`

![](./images/stripes.png)

* 2D checkerboard
`Checkered2D(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4)`

![](./images/checkered2d.png)

* 3D checkerboard
`Checkered3D(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4)`

![](./images/checkered3d.png)

* Gradient
`Gradient(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4)`

![](images/gradient.png)

## Constructive solid geometry

There are three supported operations for combining various shapes:

* Union
* Intersection
* Difference

The implementation for CSG takes advantage of so-called result builders, a feature of Swift that allows the programmer to list parameters to a function with minimal punctuation. Furthermore, Scintilla is responsible for nesting pairs of CSG operations so you don't have to, and so you can express the subtraction of three cylinders from a sphere like this:

```swift
Sphere()
    .material(.solidColor(Color(0, 0, 1)))
    .difference {
        Cylinder()
            .material(.solidColor(Color(0, 1, 0)))
            .scale(0.6, 0.6, 0.6)
        Cylinder()
            .material(.solidColor(Color(0, 1, 0)))
            .scale(0.6, 0.6, 0.6)
            .rotateZ(PI/2)
        Cylinder()
            .material(.solidColor(Color(0, 1, 0)))
            .scale(0.6, 0.6, 0.6)
            .rotateX(PI/2)
    }
```

... instead of having to do this:

```swift
CSG(.difference,
    CSG(.difference,
        CSG(.difference,
            Sphere()
                .material(.solidColor(Color(0, 0, 1)))),
            Cylinder()
                .material(.solidColor(Color(0, 1, 0)))
                .scale(0.5, 0.5, 0.5)),
        Cylinder()
            .material(.solidColor(Color(0, 1, 0)))
            .scale(0.5, 0.5, 0.5)
            .rotateZ(PI/2)),
    Cylinder()
        .material(.solidColor(Color(0, 1, 0)))
        .scale(0.5, 0.5, 0.5)
        .rotateX(PI/2))
```

You can even use `for` loops in the middle of an expression to accomplish the same:

```swift
Sphere()
    .material(.solidColor(Color(0, 0, 1)))
    .difference {
        for (thetaX, thetaZ) in [(0, 0), (0, PI/2), (PI/2, 0)] {
            Cylinder()
                .material(.solidColor(Color(0, 1, 0)))
                .scale(0.6, 0.6, 0.6)
                .rotateX(thetaX)
                .rotateZ(thetaZ)
        }
    }
```

You can also chain calls to `.union()`, `.intersection()`, and `.difference()` to create complex shapes:

```swift
Sphere()
    .material(.solidColor(Color(0, 0, 1)))
    .intersection {
        Cube()
            .material(.solidColor(Color(1, 0, 0)))
            .scale(0.8, 0.8, 0.8)
    }
    .difference {
        for (thetaX, thetaZ) in [(0, 0), (0, PI/2), (PI/2, 0)] {
            Cylinder()
                .material(.solidColor(Color(0, 1, 0)))
                .scale(0.5, 0.5, 0.5)
                .rotateX(thetaX)
                .rotateZ(thetaZ)
        }
    }
```

## Lights

Scintilla currently supports two kinds of `Light`s: `PointLight` and `AreaLight`. `PointLight` minimally requires a position to be constructed and defaults to a white color if no other one is specified. Light rays emanate from a single point, the `PointLight`'s position, and are cast on the world.

`AreaLight`s require more information in order to be constructed:

| Parameter name | Description |
| --- | --- |
| `corner` | a `Tuple4` object which represents the x, y, and z coordinates of the corner of the light source |
| `color` | the `Color` of the light source |
| `fullUVec` | a `Tuple4` object representing the direction and size of one dimension of the light source |
| `uSteps` | the number of subdivisions along the vector defined by `fullUVec` | 
| `fullVVec` | a `Tuple4` object representing the direction and magnitude of the second dimension of the light source |
| `vSteps` | the number of subdivisions along the vector defined by `fullVVec` | 

The following diagram might make it clearer to understand what the parameters represent:

```
                            --------- fullVVec ------->

                    ^      |------|------|------|------|
                    |      |      | *    |      |  *   |
                    |      | *    |      |   *  |      |
                    |      |------|------|------|------|
                    |      |      |      |  *   |     *|
                fullUVec   |    * |  *   |      |      |
                    |      |------|------|------|------|
                    |      |      |   *  |   *  |      |
                    |      |  *   |      |      |*     |
                    |      |------|------|------|------|

                        corner

```
Instead of a single point source of light, an `AreaLight` can be thought of as a rectangular one being composed of multiple cells, `uSteps`*`vSteps` in number. For each pixel to be rendered in the scene, a ray is cast from each of the cells, the position of which is randomly "jittered" from the center of each one, indicated above by asterisks. The colors associated with each light ray are then averaged and assigned to each pixel in the scene, the primary result of which is softer shadows of objects. You can see the stark difference below.

A scene rendered with a point light:

![](./images/PointLight.png)

A scene rendered with an area light with 10 subdivisions along both dimensions:

![](./images/AreaLight.png)

**NOTA BENE**: Using an `AreaLight` results in longer rendering times that are proportional to the values of the `uSteps` and `vSteps` parameters.

## Constructing a scene

To construct a scene, you need to create a `World` instance with the following objects

* a `Light`
* a `Camera`
* a body of `Shape`s

Lights and shapes are discussed above. A `Camera` takes the following four arguments:

* The width of the resultant image in pixels
* The height of the resultant image in pixels
* The solid angle in radians specifying the field of view
* A view matrix that consists of:
  * the point designating its origin
  * the point designating where it is pointing at
  * a vector representing which way is up.

`World` also supports enumerating shapes using result builders, so you can do the following:

```swift
World {
    PointLight(point(-10, 10, -10))
    Camera(800, 600, PI/3, .view(
        point(0, 3, -5),
        point(0, 0, 0),
        vector(0, 1, 0)))
    Sphere()
        .material(.solidColor(Color(1, 0, 0)))
        .translate(-2, 0, 0)
    Sphere()
        .material(.solidColor(Color(0, 1, 0)))
    Sphere()
        .material(.solidColor(Color(0, 0, 1)))
        .translate(2, 0, 0)
```

Note the lack of commas separating the parameters to the `World` constructor as well as not needing brackets around the `Sphere` objects.

## Rendering a scene

Scintilla comes with a component that allows you to easily create an application and render a scene. In order to do this, first create a new Xcode project, using the Command Line Tool template. 

![](./images/CLI_template.png)

Next add Scintilla as a package dependency via File -> Add Packages; in that dialog box, enter the URL of this Git repository and click Add Package. Xcode should successfully download the library and add it to the project.

Now that you're ready to use Scintilla, all you need to do is create a new Swift file, say `MyWorld.swift`. Add the following code as an example scene:

```swift
import ScintillaLib

@main
struct MyWorld: ScintillaApp {
    var body = World {
        PointLight(point(-10, 10, -10))
        Camera(800, 600, PI/3, .view(
            point(0, 1, -2),
            point(0, 0, 0),
            vector(0, 1, 0)))
        Sphere()
            .material(.solidColor(Color(0, 0, 1)))
            .intersection {
                Cube()
                    .material(.solidColor(Color(1, 0, 0)))
                    .scale(0.8, 0.8, 0.8)
            }
            .difference {
                for (thetaX, thetaZ) in [(0, 0), (0, PI/2), (PI/2, 0)] {
                    Cylinder()
                        .material(.solidColor(Color(0, 1, 0)))
                        .scale(0.5, 0.5, 0.5)
                        .rotateX(thetaX)
                        .rotateZ(thetaZ)
                }
            }
            .rotateY(PI/6)
    }
}
```

Please note the following about the example above:

* You must `import ScintillaLib`
* You need to annotate the struct with `@main`
* Your struct must conform to the `ScintallaApp` protocol
* The struct must have the `body` property, which is of type `World`

If you've done all that, you now have a bona fide application and should be able to run it through Xcode. And if all goes well, you should see the file `MyWorld.ppm` on your desktop and it should look like this:

![](./images/MyWorld.png)

You can also optionally render a scene with antialiasing. In the image above, you can see that the various edges of the object are pretty jagged and take away from the verisimilitude of the image. By adding a property modifier to the `World` object, `.antialiasing(true)`, we can improve its quality:

```
import ScintillaLib

@main
struct CSGExample: ScintillaApp {
    var body = World {
        PointLight(point(-10, 10, -10))
        Camera(400, 400, PI/3, .view(
            point(0, 1.5, -2),
            point(0, 0, 0),
            vector(0, 1, 0)))
        Sphere()
            .material(.solidColor(Color(0, 0, 1)))
            .intersection {
                Cube()
                    .material(.solidColor(Color(1, 0, 0)))
                    .scale(0.8, 0.8, 0.8)
            }
            .difference {
                for (thetaX, thetaZ) in [(0, 0), (0, PI/2), (PI/2, 0)] {
                    Cylinder()
                        .material(.solidColor(Color(0, 1, 0)))
                        .scale(0.5, 0.5, 0.5)
                        .rotateX(thetaX)
                        .rotateZ(thetaZ)
                }
            }
            .rotateY(PI/6)
    }
        .antialiasing(true)
}
```

... and below is the resultant image:

![](./images/Antialiasing.png)

Because rendering times are much slower with antialiasing turned out, you should make sure that the run configuration is set to Release in order to run Swift in the fastest fashion. To get there, go to Product -> Scheme -> Edit Scheme...

![](./images/SchemeSettings.png)

## Adding new scenes

You can have multiple scenes in a single project by adding new targets via File -> New -> Target... Just make sure that ScintillaLib is included as a library in the target; go to the project navigator, click on the project name, then the target name in the editor pane, then the General tab.

![](./images/Libraries.png)

## Relevant links

* The Ray Tracer Challenge by Jamis Buck  
  [https://pragprog.com/titles/jbtracer/the-ray-tracer-challenge/](https://pragprog.com/titles/jbtracer/the-ray-tracer-challenge/)
* Result builders  
  [https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630)