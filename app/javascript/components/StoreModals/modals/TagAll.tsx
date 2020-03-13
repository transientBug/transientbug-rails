import React, { useState } from "react"
import { ModalClose } from "./types"
import { ValueType } from "react-select/src/types"

import * as Modal from "../../Modal"
import Button from "../../Button"
import CreatableSelect from "react-select/async-creatable"

import { get, bulk } from "../../../api"

import Turbolinks from "turbolinks"
import pluralize from "pluralize"
import { debounce } from "lodash"

import { connect } from "react-redux"
import { RootState } from "../../../store/store"

interface OwnProps {
  close: ModalClose
  url: string
  autocompleteUrl: string
}

interface StateProps {
  ids: number[]
  wording: string
}

type TagAllModalProps = OwnProps & StateProps

const TagAllModal: React.FC<TagAllModalProps> = ({
  close,
  ids,
  wording,
  url,
  autocompleteUrl
}) => {
  const [tags, setTags] = useState([])

  const count = ids.length
  const pluralString = pluralize(`${count} ${wording}`, count)

  const tagAll = async () => {
    await bulk.tag(url, ids, tags.map(tag => tag.value))
    Turbolinks.visit(window.location, { replace: true })
  }

  const tagsOnChange = (value: ValueType<{ label: string; value: string }>) => {
    if (!value) return
    if (!Array.isArray(value)) return

    setTags(value)
  }

  const baseUrl = new URL(autocompleteUrl, window.location.href)
  const searchParams = new URLSearchParams()

  const promiseOptions = debounce(async (input, callback) => {
    searchParams.set("q", input)
    baseUrl.search = searchParams.toString()

    const finalUrl = baseUrl.toString()

    const response = await get(finalUrl)
    const { results } = await response.json()

    const tags = results.map(tag => ({ value: tag.label, label: tag.label }))

    callback(tags)

    return tags
  }, 500)

  return (
    <div className="modal-dialogue light-dialogue">
      <Modal.Header>
        <h2>Add Tags to Selected {pluralString}?</h2>
        <Modal.Close onClick={close} />
      </Modal.Header>
      <Modal.Content className="overflow-visible">
        <p>
          This will add all the given tags to the selected {pluralString}, but
          will not replace or overwrite any existing tags.
        </p>
        <CreatableSelect
          isClearable
          isMulti
          name="tags"
          placeholder="Tags"
          value={tags}
          onChange={tagsOnChange}
          loadOptions={promiseOptions}
          styles={{
            placeholder: base => ({ ...base, color: "#a8adb6" })
          }}
        />
      </Modal.Content>
      <Modal.Actions>
        <Button
          className="self-start button-gray-outline hover:button-light-gray shadow hover:shadow-md"
          onClick={tagAll}
        >
          Add Tags to {pluralString}
        </Button>
        <Button
          className="button-white hover:button-light-gray shadow hover:shadow-md"
          onClick={close}
        >
          Cancel
        </Button>
      </Modal.Actions>
    </div>
  )
}

export default connect(
  ({ records, selection }: RootState) => ({
    ids: selection.selection,
    wording: records.type
  }),
  {}
)(TagAllModal)
