| import 'components/imagemanager.tag'

images-manager
    imagemanager(dblclick='{ dblclick }')


    script(type='text/babel').
        var self = this,
            route = riot.route.create()

        self.callback = ''

        route(page => {
            if (page == 'imageLoad') {
                self.tags.imagemanager.reload()
                self.update()
            }
        })

        self.dblclick = e => {
            //console.log(e)
            window.top.opener.CKEDITOR.tools.callFunction( self.callback, e.item.url);
            window.top.close() ;
            window.top.opener.focus()
        }

        self.on('mount', () => {
            riot.route.exec()
            self.callback = riot.route.query()
            self.callback = self.callback['CKEditorFuncNum']
        })








