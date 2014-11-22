class AC.DragAndDrop
    @options = no_css: true
    @jquery_register: (obj, method, options, fun)->
         new AC.DragAndDrop.Register(obj, method, options, fun)

class AC.DragAndDrop.Register
    constructor: (obj, method, options, fun)->
        @obj = obj
        @options = @options
        if (@check_params(method, options, fun) == 0)
            @execute_method()
        else 
            console.error(@error_message)

    execute_method: ()->
        if (@method == 'register')
            if (@options.no_css == false)
                @obj.addClass("div_for_drag_and_drop_files");
            @start_drag_and_drop_files();
        else if (@method == 'remove') 
            @stop_drag_and_drop_files();
            if (_.isFunction(this.fun))
                @fun(@obj);

    check_params: (method, options, fun)->
        if (_.isString(method))
            @method = method
            if (_.isObject(options)) 
                @options = $.merge(options, AC.DragAndDrop.options)
            if (_.isFunction(options)) 
                @fun = fun
        else if (_.isFunction(method)) 
            @fun = method;
            @method = 'register'
        else if (_.isObject(method)) 
            @options = $.merge(method, AC.DragAndDrop.options)
            @method = 'register'
            if (_.isFunction(options)) 
                @fun = options
        else if (_.isUndefined(method)) 
            @method = 'register'
        if (_.isObject(options)) 
            @options = $.merge(options, AC.DragAndDrop.options);
        @method = @method || method;
        @fun = @fun || fun;
        @options = @options || AC.DragAndDrop.options;
        0
        # ----------------------- div drag & drop handlers ------------------------------ //
    div_dragenter_event: (e)->
        e.stopPropagation()
        e.preventDefault()
        if (e.data.obj.options.no_css == false)
            $(this).css('border', '2px solid #0B85A1')
    div_drop_event: (e)->
        if (e.data.obj.options.no_css == false) 
            $(this).css('border', '2px dotted #0B85A1')
        e.preventDefault()
        if (e.originalEvent.dataTransfer && e.originalEvent.dataTransfer.files)
            files = e.originalEvent.dataTransfer.files
            e.data.obj.files_dropped(files, $(this))
        else
            console.warn('this browser does not support drag & drop files')
    div_dragover_event: (e)->
        e.stopPropagation()
        e.preventDefault()
        # ----------------------- div drag & drop handlers END -------------------------- //
    prevent_document_dragenter_event: (e)->
        e.stopPropagation();
        e.preventDefault();
    prevent_document_dragover_event: (e)->
        e.stopPropagation()
        e.preventDefault()
        if (e.data.obj.options.no_css == false)
            $(this).css('border', '2px dotted #0B85A1')
    prevent_document_drop_event: (e)->
        e.stopPropagation()
        e.preventDefault()

    start_drag_and_drop_files: ()->
        this.obj.on('dragenter', {obj: this}, this.div_dragenter_event);
        this.obj.on('dragover', this.div_dragover_event);
        this.obj.on('drop', {obj: this}, this.div_drop_event);

        $(document).on('dragenter', this.prevent_document_dragenter_event);
        $(document).on('dragover', {obj: this}, this.prevent_document_dragover_event);
        $(document).on('drop', this.prevent_document_drop_event);
    stop_drag_and_drop_files: ()->
        this.obj.off('dragenter', this.div_dragenter_event);
        this.obj.off('dragover', this.div_dragover_event);
        this.obj.off('drop', this.div_drop_event);
        $(document).off('dragenter', this.prevent_document_dragenter_event);
        $(document).off('dragover', this.prevent_document_dragover_event);
        $(document).off('drop', this.prevent_document_drop_event);
    files_dropped: (files, obj)->
        filelist = files;
        files_array = _.uniq(_.map(files, (file)->
            file;
        ))
        if (_.isFunction(this.fun))
            this.fun(files_array, obj, filelist)
        else 
            this.default_dropped_fun(files_array, obj, filelist)
    default_dropped_fun: (files, obj, filelist)->
        if (_.isArray(files))
            _.each(files, (file)->
                reader = new FileReader();

                reader.onload = `(function (theFile) {
                    return function (event) {
                        if (theFile.type.match(/image\/*/)) {
                            var img = $('<img src="' + event.target.result + '" width="100px" height="100px" ></img>');
                            obj.append(img);
                        } else if (theFile.type.match(/application\/x\-yaml/)) {
                        } else if (theFile.type.match(/\/pdf/)) {
                            console.log('pdf dropped');
                        } else {
                        }
                    }
                })(file)`

                reader.onerror = (event)->
                    console.error("File could not be read! Code " + event.target.error.code)
                reader.readAsDataURL(file);
            );

$.fn.extend
    drag_and_drop: (method, options, fun)->
        @.each ()->
            AC.DragAndDrop.jquery_register($(@), method, options, fun)