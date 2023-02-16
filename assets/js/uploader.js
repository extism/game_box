const s3Uploader = (entries, onViewError) => {

  entries.forEach((entry) => {
    const formData = new FormData()
    const {url, fields} = entry.meta
    Object.entries(fields).forEach(([key, val]) => formData.append(key, val))
    formData.append("file", entry.file)
    const xhr = new XMLHttpRequest()
    onViewError(() => xhr.abort() )
    xhr.onload = () => {
      xhr.status === 204 ? entry.progress(100) : entry.error()
    }
    xhr.onerror = () => entry.error()
    xhr.upload.addEventListener("progress", (event) => {
      if(event.lengthComputable){
        const percent = Math.round((event.loaded / event.total) * 100)
        if(percent < 100){ entry.progress(percent) }
      }
    })

    xhr.open("POST", url, true)
    xhr.send(formData)
  })
}

export {s3Uploader}
