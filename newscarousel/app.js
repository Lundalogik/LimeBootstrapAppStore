lbs.apploader.register('newscarousel', function () {
    var self = this;

    this.config = {
        dataSources: [
            { type: 'storedProcedure', source: 'csp_app_newscarousel_getxml', alias: 'newsSrc' }
        ],
        resources: {
            scripts: ['lodash.min.js', 'marked.js'],
            styles: ['app.css'],
            libs: ['json2xml.js']
        }
    };

    this.initialize = function(node, viewModel) {
        var newsData = viewModel.newsSrc.data ? viewModel.newsSrc.data.news || [] : [];

        if (!_.isArray(newsData)) {
            newsData = [newsData];
        }

        viewModel.uniqueId = 'carousel-' + Math.random().toString(36).substring(2);
        viewModel.news = ko.observableArray(newsData);

        return viewModel;
    };

    if (_.isUndefined(ko.bindingHandlers.markdown)) {
        ko.bindingHandlers.markdown = {
            update: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
                var markdown = ko.utils.unwrapObservable(valueAccessor());
                var html = marked(markdown);
                ko.bindingHandlers.html.update(element, function() {
                    return html;
                });
            }
        };
    }
});