import axios from "axios";

export const LocalServer = axios.create({
  baseURL: location.origin,
});
