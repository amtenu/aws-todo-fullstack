import { useState } from "react";
import { useAppDispatch } from "@/store/hooks";
import { toggleTodo, deleteTodo, updateTodo } from "@/store/slices/todoSlice";
import { Trash2, Edit2, Check, X } from "lucide-react";
import type { Todo } from "@/types/index";

interface TodoItemProps {
  todo: Todo;
}

export default function TodoItem({ todo }: TodoItemProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [editTitle, setEditTitle] = useState(todo.title);
  const [editDescription, setEditDescription] = useState(
    todo.description || "",
  );
  const dispatch = useAppDispatch();

  const handleToggle = () => {
    dispatch(toggleTodo(todo.id));
  };

  const handleDelete = () => {
    if (window.confirm("Are you sure you want to delete this todo?")) {
      dispatch(deleteTodo(todo.id));
    }
  };

  const handleSave = async () => {
    if (!editTitle.trim()) return;

    await dispatch(
      updateTodo({
        id: todo.id,
        data: {
          title: editTitle.trim(),
          description: editDescription.trim() || undefined,
        },
      }),
    );
    setIsEditing(false);
  };

  const handleCancel = () => {
    setEditTitle(todo.title);
    setEditDescription(todo.description || "");
    setIsEditing(false);
  };

  if (isEditing) {
    return (
      <div className="card animate-slide-up">
        <input
          type="text"
          value={editTitle}
          onChange={(e) => setEditTitle(e.target.value)}
          className="input mb-2"
          autoFocus
        />
        <textarea
          value={editDescription}
          onChange={(e) => setEditDescription(e.target.value)}
          placeholder="Description (optional)"
          className="input resize-none mb-3"
          rows={2}
        />
        <div className="flex gap-2">
          <button onClick={handleSave} className="btn btn-primary flex-1">
            <Check size={18} className="mr-1" />
            Save
          </button>
          <button onClick={handleCancel} className="btn btn-secondary flex-1">
            <X size={18} className="mr-1" />
            Cancel
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="card hover:shadow-md transition-shadow animate-slide-up">
      <div className="flex items-start gap-3">
        {/* Checkbox */}
        <input
          type="checkbox"
          checked={todo.completed}
          onChange={handleToggle}
          className="mt-1 h-5 w-5 rounded border-gray-300 text-primary-600 focus:ring-primary-500 cursor-pointer"
        />

        {/* Content */}
        <div className="flex-1 min-w-0">
          <h3
            className={`font-medium ${
              todo.completed ? "line-through text-gray-400" : "text-gray-900"
            }`}
          >
            {todo.title}
          </h3>
          {todo.description && (
            <p
              className={`text-sm mt-1 ${
                todo.completed ? "text-gray-400" : "text-gray-600"
              }`}
            >
              {todo.description}
            </p>
          )}
          <p className="text-xs text-gray-400 mt-2">
            {new Date(todo.CreatedAt).toLocaleDateString()}
          </p>
        </div>

        {/* Actions */}
        <div className="flex gap-2">
          <button
            onClick={() => setIsEditing(true)}
            className="text-gray-400 hover:text-primary-600 transition"
            title="Edit"
          >
            <Edit2 size={18} />
          </button>
          <button
            onClick={handleDelete}
            className="text-gray-400 hover:text-red-600 transition"
            title="Delete"
          >
            <Trash2 size={18} />
          </button>
        </div>
      </div>
    </div>
  );
}
