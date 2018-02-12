
      // Full list of configuration options available at:
      // https://github.com/hakimel/reveal.js#configuration
      Reveal.initialize({
        controls: false,
        progress: true,
        history: true,
        center: true,

//        transition: 'slide', // none/fade/slide/convex/concave/zoom

        // Optional reveal.js plugins
        dependencies: [
          { src: '../js/reveal-js/lib/js/classList.js', condition: function() { return !document.body.classList; } },
          { src: '../js/reveal-js/plugin/markdown/marked.js', condition: function() { return !!document.querySelector( '[data-markdown]' ); } },
          { src: '../js/reveal-js/plugin/markdown/markdown.js', condition: function() { return !!document.querySelector( '[data-markdown]' ); } },
          { src: '../js/reveal-js/plugin/highlight/highlight.js', async: true, callback: function() { hljs.initHighlightingOnLoad(); } },
          { src: '../js/reveal-js/plugin/zoom-js/zoom.js', async: true },
          { src: '../js/reveal-js/plugin/notes/notes.js', async: true }
        ]
      });
