JsOsaDAS1.001.00bplist00�Vscript_#const getObjectId = (() => {
    let count = 0;
    const objIdMap = new WeakMap();
    return (object) => {
      const objectId = objIdMap.get(object);
      if (objectId === undefined) {
        count += 1;
        objIdMap.set(object, count);
        return count;
      }
    
      return objectId;
    }
})();


const objectCacheMap = {};

function cacheObjct(obj) {
    let id = getObjectId(obj);
    objectCacheMap[id] = obj;
    return id;
}

function getCachedObject(id) {
    return objectCacheMap[id];
}

function jsonIOWrapper(func) {
    return (param_str) => {
        let param = JSON.parse(param_str);
        let result = func(param);
        return JSON.stringify(result);
    }
}

function isJsonNodeValue(obj) {
    return obj === null || ['undefined', 'string', 'number', 'boolean'].includes(typeof obj);
}

function isPlainObj(obj) {
    if (isJsonNodeValue(obj)) {
        return true;
    } else if (typeof obj === 'object') {
        for (let k in obj) {
            if (!isJsonNodeValue(obj[k])) {
                return false;
            }
        }
        return true;
    } else if (typeof obj === 'function') {
        return false;
    }
}


function wrapObjToJson(obj) {

    if (isJsonNodeValue(obj)) {
        return {
            type: 'value',
            data: obj
        }
    }

    if (typeof obj === 'object') {
        if (obj instanceof Date) {
            return {
                type: 'value',
                data: obj.toISOString()
            }
        }
        if (Array.isArray(obj)) {
            let data = []
            for (let i in obj) {
                data[i] = wrapObjToJson(obj[i]);
            }
            return {
                type: 'container',
                data: data
            }
        }
        if (obj.constructor.name === 'Object') {
            let data = {}
            for (let k in obj) {
                data[k] = wrapObjToJson(obj[k]);
            }
            return {
                type: 'container',
                data: data
            }
        }

        throw new Error(`wrapObjToJson: Unknown type: ${typeof obj}`);
    }

    if (ObjectSpecifier.hasInstance(obj)) {
        let classOf = ObjectSpecifier.classOf(obj);
        let evaluated = obj();
        if (evaluated !== undefined && !ObjectSpecifier.hasInstance(evaluated)) {
            return wrapObjToJson(evaluated);
        }

        return {
            type: 'reference',
            objId: cacheObjct(obj),
            className: classOf
        }
    }
    
    throw new Error(`Unknown type: ${typeof obj}`);
}

function unwrapObjFromJson(obj) {
    if (obj.type === 'value') {
        return obj.data;
    } else if (obj.type === 'container') {
        for (let k in obj.data) {
            obj.data[k] = unwrapObjFromJson(obj.data[k]);
        }
        return obj.data;
    } else if (obj.type === 'reference') {
        return getCachedObject(obj.objId);
    }
}

function getApplication(params) {
    let name = params.name;
    let app = Application(name);
    app.includeStandardAdditions = true
    return wrapObjToJson(app);
}
getApplication = jsonIOWrapper(getApplication);

function getProperties(params) {
    let objId = params.objId;
    let names = params.names;
    let obj = objectCacheMap[objId];
    let data = {};
    for (let n of names) {
        let property = obj[n];
        data[n] = wrapObjToJson(property);
    }
    return data;
}
getProperties = jsonIOWrapper(getProperties);


function setPropertyValues(params) {
    let objId = params.objId;
    let properties = params.properties;

    let obj = objectCacheMap[objId];

    for (let n in properties) {
        let value = properties[n];
        obj[n] = value;
    }
    return {};
}
setPropertyValues = jsonIOWrapper(setPropertyValues);

function runMethod(params) {
    let objId = params.objId;
    let name = params.name;
    let args = params.args;
    for (let i = 0; i < args.length; i++) {
        args[i] = unwrapObjFromJson(args[i]);
    }
    let kwargs = {};
    for (let k in params.kwargs) {
        kwargs[k] = unwrapObjFromJson(params.kwargs[k]);
    }

    let obj = objectCacheMap[objId];
    let result = obj[name](...args, kwargs);
    return wrapObjToJson(result);
}
runMethod = jsonIOWrapper(runMethod);


function releaseObject(params) {
    let objId = params.objId;
    delete objectCacheMap[objId];
    return {};
}
releaseObject = jsonIOWrapper(releaseObject);

function callSelf(params) {
    let objId = params.objId;
    let args = params.args;
    
    for (let i = 0; i < args.length; i++) {
        args[i] = unwrapObjFromJson(args[i]);
    }
    let kwargs = {};
    for (let k in params.kwargs) {
        kwargs[k] = unwrapObjFromJson(params.kwargs[k]);
    }
    let obj = objectCacheMap[objId];
    let result = obj(...args, kwargs);
    return wrapObjToJson(result);
}
callSelf = jsonIOWrapper(callSelf);                              9 jscr  ��ޭ