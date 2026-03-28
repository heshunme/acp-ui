// Types for ACP UI application

export interface AgentConfig {
  command: string;
  args: string[];
  env?: Record<string, string>;
}

export interface AgentsConfig {
  agents: Record<string, AgentConfig>;
}

export interface AgentInstance {
  id: string;
  name: string;
}

export interface AgentMessage {
  agent_id: string;
  message: string;
}

export interface AgentStderr {
  agent_id: string;
  line: string;
}

export interface SavedSession {
  id: string;
  agentName: string;
  sessionId: string;
  title: string;
  lastUpdated: number;
  cwd: string;
  supportsLoadSession?: boolean; // Whether the agent supports session/load
}

export interface ChatMessage {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  parts?: AssistantMessagePart[];
}

export type AssistantMessagePart =
  | AssistantTextPart
  | AssistantThoughtPart
  | AssistantToolPart;

export interface AssistantTextPart {
  id: string;
  type: 'text';
  content: string;
}

export interface AssistantThoughtPart {
  id: string;
  type: 'thought';
  content: string;
}

export interface AssistantToolPart {
  id: string;
  type: 'tool';
  toolCall: ToolCallInfo;
}

export interface ToolCallInfo {
  toolCallId: string;
  title: string;
  kind: string;
  status: 'pending' | 'in_progress' | 'completed' | 'failed';
  locations?: { path: string }[];
}

export interface PermissionRequest {
  sessionId: string;
  toolCall: ToolCallInfo;
  options: PermissionOption[];
}

export interface PermissionOption {
  kind: string;
  name: string;
  optionId: string;
}

// Session Modes
export interface SessionMode {
  id: string;
  name: string;
  description?: string;
}

export interface SessionModeState {
  currentModeId: string;
  availableModes: SessionMode[];
}

// Slash Commands
export interface SlashCommand {
  name: string;
  description: string;
  hint?: string;
}

// Models
export interface ModelInfo {
  modelId: string;
  name: string;
  description?: string;
}
