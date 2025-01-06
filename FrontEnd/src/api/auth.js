import axios from "axios";

const API_URL = "https://madmaxbackend.onrender.com/api/auth"; // Update with your backend URL

// Signup
export const signup = async (email, password) => {
  const response = await axios.post(`${API_URL}/signup`, { email, password });
  return response.data;
};

// Login
export const login = async (email, password) => {
  const response = await axios.post(`${API_URL}/login`, { email, password });
  return response.data;
};

// Verify Email
export const verifyEmail = async (token) => {
  const response = await axios.get(`${API_URL}/verify/${token}`);
  return response.data;
};
