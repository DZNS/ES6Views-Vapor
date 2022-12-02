# ES6Views-Vapor

A Vapor View engine for [ES6Views](https://github.com/DZNS/ES6Views)

### Usage 
```swift
// In app configuration
app.views.use(.es6views)

// In a route 
let data: [String: String] = [
  "title" : "My App",
  "username": "@username"
]

return try await req.view.render("home/welcome", data)
```

### Installation 
1. Add `https://github.com/DZNS/ES6Views-Vapor.git` to your `Package.swift`
```swift 
// In Package dependencies 
.package(url: "https://github.com/DZNS/ES6Views-Vapor.git", branch: "main")

// In Target dependencies 
.product(name: "ES6Views", package: "ES6Views")
```

2. Install `es6views` under `Resources/Views`
```sh
npm init 
npm install --save es6views 
``` 

3. Create a new file under `Resources/Views` called `layout.es6` with the following contents:
<details>
<summary>layout.es6</summary>
<pre><code>
class ModelView {

    constructor(data) {
        if(data) this.data = data;
    }

    set data(newData) {
        this._data = newData;
        this._markup = undefined;
    }

    get data() {
        return this._data;
    }

    get markup() {
        if(!this._markup) {
            this.parse();
        }

    return (this._markup || "").trim();
    }

    get minified() {
        return ModelView.minify(this.markup);
    }

    parse() {
        console.log("Subclasses should implement how views are drawn. Do not call super. It does nothing.");

        return undefined;
    }

    static minify(html) {
        return html.replace(/\r?\n?/gim, "").replace(/\s{2,10000}/gim,"");
    }
}

class Layout extends ModelView {

    constructor(locals) {
        super(locals||{});
    
        this._locals = locals;

        this.setup();
    }

    async setup() {
        if(!this._locals.renderPartial) {
            if (this.parse.constructor.name === 'AsyncFunction') {}
            else {
                this.parse();
            }
        }
    }

    parse() {
        throw new Error("You should write your common layout logic in a subclass of Layout. When you're done, simply call super with your rendered interstetials.");

      /*
       * In your View subclass
          var header = "...";
          var main = "...";
          var footer ="...";
          super.parse(
              header,
              main,
              footer
          )
       */

      /*
       * In your layout subclass
      
          var html = Array.prototype.slice.call(arguments).join("");
          this._markup = html;

      */
    }
}

module.exports = Layout
</pre></code>
</details>

You can then reference `layout.es6` in your views 

#### Todo

- [ ] Result/View Caching  
